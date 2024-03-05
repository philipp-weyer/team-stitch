exports = async function(request){


  
  // Find the name of the MongoDB service you want to use (see "Linked Data Sources" tab)
  var serviceName = "mongodb-atlas";
  var dbName = "stitch-crawler";
  var collName = "embedded-messages";
  
  
  // Get a collection from the context
  var collection = context.services.get(serviceName).db(dbName).collection(collName);
  const requestBody = JSON.parse(request.body.text());
  console.log(requestBody);
  
  
  try {
    
    query = await collection.insertOne(requestBody);
   
  } catch(err) {
    console.log("Error occurred while executing findOne:", err.message);

    return { error: err.message };
  }

  return { result: query };
};