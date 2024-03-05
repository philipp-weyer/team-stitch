exports = async function(arg){

  let azure_url = context.values.get('azure_url')
  let azure_key = context.values.get('azure_key_value')
  
  const res = await context.http.post({
      "scheme": "https",
      "host": azure_url,
      "path": "computervision/retrieval:vectorizeText",
      "query": { "api-version": [ "2023-02-01-preview" ]},
      "headers": {
        "Content-Type": [ "application/json" ],
        "Ocp-Apim-Subscription-Key": [ azure_key ]
      },
      "body": { "text": arg },
      "encodeBodyAsJSON": true
    })

  let ret = {}
  try {
    const embedding = JSON.parse(res.body.text());
    ret.success = true;
    ret.vector = embedding.vector;
  } catch (err) {
    ret.success = false;
    ret.error = err;
  }
  
  return ret;
};