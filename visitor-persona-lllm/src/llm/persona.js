const OpenAI = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

async function generatePersona(visitor) {
  const prompt = `
You are an academic visitor profiling assistant.

Analyze the following visitor data and generate a concise but informative
persona summary (1–2 paragraphs).

Rules:
- Academic neutral tone
- No recommendations
- No storytelling
- Identify visitor type and behavior

Visitor Data:
Age Group: ${visitor.age_group}
Time Budget: ${visitor.time_budget}
Visit Purpose: ${visitor.visit_purpose}
Language Level: ${visitor.language_level}
Architecture Interest: ${visitor.interest_architecture}
History Interest: ${visitor.interest_history}
Spirituality Interest: ${visitor.interest_spirituality}
Art Interest: ${visitor.interest_art}
Visited Before: ${visitor.visited_before ? 'Yes' : 'No'}
Explanation Preference: ${visitor.explanation_type}
Timeline Direction: ${visitor.timeline_direction}
Buddhist History Knowledge: ${visitor.buddhist_history_knowledge ? 'Yes' : 'No'}
`;

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    temperature: 0.3,
    messages: [
      { role: 'system', content: 'You generate evaluatable visitor personas.' },
      { role: 'user', content: prompt }
    ]
  });

  return response.choices[0].message.content;
}

module.exports = generatePersona;
