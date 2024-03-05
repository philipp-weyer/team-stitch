// Header: MongoDB Atlas Function to Process Document Changes
// Inputs: MongoDB changeEvent object
// Outputs: Updates the MongoDB document with processing status and Azure AI model vector

exports = async function(changeEvent) {

  var serviceName = "mongodb-atlas";
  var dbName = changeEvent.ns.db;
  var collName = changeEvent.ns.coll;
  
  if (changeEvent.operationType === "update" && !("title" in changeEvent.updateDescription.updatedFields))
    return false

  let doc = changeEvent.fullDocument
  try {
    var collection = context.services.get(serviceName).db(dbName).collection(collName);

    // Set document status to 'pending'
    await collection.updateOne({'_id' : doc._id}, {$set : {processing : 'pending'}});

    // { success: boolean, vector: [float], error: error}
    const embedding = await context.functions.execute("getTextEmbedding", doc.title )
    if (embedding.success) {
      doc.vector = embedding.vector
    } else {
      delete doc.vector;
      console.error(embedding.error);
    }
    doc.processing = 'completed';
    await collection.updateOne({'_id' : doc._id}, {$set : doc});
  } catch(err) {
    console.error(err)
  }
  return true
};