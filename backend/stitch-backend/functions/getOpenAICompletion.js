// arg = { ctx: [ String ], query: String }
exports = async function(arg){
  // let openai_key = context.values.get('openai_key_value')
  const openai_key = "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";
  
  const query = {
    model: "gpt-4-turbo-preview",
    messages: [
        {
          "role": "user",
          "content": createPrompt(arg.ctx, arg.query)
        }
      ]
  }
  let res = await context.http.post({
      "scheme": "https",
      "host": "api.openai.com",
      "path": "v1/chat/completions",
      "query": null,
      "headers": {
        "Content-Type": [ "application/json" ],
        "Authorization": [ `Bearer ${openai_key}` ]
      },
      "body": query,
      "encodeBodyAsJSON": true
    })

  const response_object = JSON.parse(res.body.text());
  const answer = response_object.choices[0].message.content;
  
  return answer;
};

function createPrompt (ctx, query) 
{
  const formatted_context = "Keep this context in mind:\n- " + ctx.join("\n- ")
  
  const formatted_query = `Now answer this question: ${query}`;
  
  const prompt = `${formatted_context}\n${formatted_query}`; 
  console.log (prompt);
  return prompt;
}