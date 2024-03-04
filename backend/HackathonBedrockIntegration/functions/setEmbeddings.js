// Header: MongoDB Atlas Function to Process Document Changes
// Inputs: MongoDB changeEvent object
// Outputs: Updates the MongoDB document with processing status and AWS model response

exports = async function(changeEvent) {
 // Connect to MongoDB service
 var serviceName = "mongodb-atlas";
 var dbName = changeEvent.ns.db;
 var collName = changeEvent.ns.coll;

 try {
   var collection = context.services.get(serviceName).db(dbName).collection(collName);

   // Set document status to 'pending'
   await collection.updateOne({'_id' : changeEvent.fullDocument._id}, {$set : {processing : 'pending'}});

   // AWS SDK setup for invoking models
   const { BedrockRuntimeClient, InvokeModelCommand } = require("@aws-sdk/client-bedrock-runtime");
   const client = new BedrockRuntimeClient({
     region: 'us-east-1',
     credentials: {
       accessKeyId:  context.values.get('AWS_ACCESS_KEY'),
       secretAccessKey: context.values.get('AWS_SECRET_KEY')
     },
     model: "amazon.amazon.titan-embed-image-v1",
   });

   // Prepare embedding input from the change event
   let embedInput = {}
   if (changeEvent.fullDocument.title) {
     embedInput['inputText'] = changeEvent.fullDocument.title
   }
   if (changeEvent.fullDocument.imgUrl) {
     const imageResponse = await context.http.get({ url: changeEvent.fullDocument.imgUrl });
     const imageBase64 = imageResponse.body.toBase64();
     embedInput['inputImage'] = imageBase64
   }

   // AWS SDK call to process the embedding
   const input = {
     "modelId": "amazon.titan-embed-image-v1",
     "contentType": "application/json",
     "accept": "*/*",
     "body": JSON.stringify(embedInput)
   };

   console.log(`before model invoke ${JSON.stringify(input)}`);
   const command = new InvokeModelCommand(input);
   const response = await client.send(command);
    
   // Parse and update the document with the response
   const doc = JSON.parse(Buffer.from(response.body));
   doc.processing = 'completed';
   await collection.updateOne({'_id' : changeEvent.fullDocument._id}, {$set : doc});

 } catch(err) {
   // Handle any errors in the process
   console.error(err)
 }
};