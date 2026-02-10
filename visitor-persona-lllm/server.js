import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import OpenAI from "openai";
import db from "./src/db/mysql.js";
import { validatePersona } from "./src/validation/personaValidator.js";
import { normalizeVisitor } from "./src/utils/normalizeVisitor.js";


dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});


// Health check
app.get("/", (req, res) => {
  res.send("✅ Persona Service running");
});


// Persona endpoint
app.post("/persona-summary", async (req, res) => {
  console.log("✅ /persona-summary HIT");
  const v = normalizeVisitor(req.body);
  // 🔁 Map buddhist history knowledge to INT for DB
const knowledgeMap = {
  None: 0,
  Basic: 1,
  Intermediate: 2,
  Advanced: 3
};

const buddhistHistoryKnowledgeDB =
  knowledgeMap[v.buddhist_history_knowledge] ?? 0;


  try {
    

    // 1️⃣ Prompt
    const prompt = `
You are an intelligent visitor profiling assistant.

Generate a concise but informative visitor persona summary
based ONLY on the following attributes.

Age Group: ${v.age_group}
Time Budget: ${v.time_budget}
Visit Purpose: ${v.visit_purpose}
Language Level: ${v.language_level}
Interest Architecture: ${v.interest_architecture}
Interest History: ${v.interest_history}
Interest Spirituality: ${v.interest_spirituality}
Interest Art: ${v.interest_art}
Visited Before: ${v.visited_before}
Explanation Type: ${v.explanation_type}
Timeline Direction: ${v.timeline_direction}
Buddhist History Knowledge: ${v.buddhist_history_knowledge}
`;

    let personaSummary = "";
    let validationResult = { passed: false, confidence: 0 };
    let attempts = 0;

    // 2️⃣ Generate → Validate (max 3 tries)
    while (!validationResult.passed && attempts < 3) {
      const llmResponse = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        temperature: 0.3,
        messages: [
          { role: "system", content: "You generate evaluatable visitor persona summaries." },
          { role: "user", content: prompt }
        ]
      });

      personaSummary = llmResponse.choices[0].message.content;
      validationResult = validatePersona(v, personaSummary);

      console.log("🔍 Validation Result:", validationResult);
      console.log("📊 Confidence Score:", validationResult.confidence);
      console.log("📝 Persona Summary:\n", personaSummary);

      attempts++;
    }

    // 3️⃣ Reject if still invalid
    if (!validationResult.passed) {
      return res.status(422).json({
        error: "Persona failed validation after multiple attempts",
        confidence: validationResult.confidence
      });
    }

    // 4️⃣ Save to DB
    const query = `
      INSERT INTO visitor (
        age_group,
        time_budget,
        visit_purpose,
        language_level,
        interest_architecture,
        interest_history,
        interest_spirituality,
        interest_art,
        visited_before,
        explanation_type,
        timeline_direction,
        buddhist_history_knowledge,
        persona_summary,
        confidence_score
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const values = [
      v.age_group,
      v.time_budget,
      v.visit_purpose,
      v.language_level,
      v.interest_architecture,
      v.interest_history,
      v.interest_spirituality,
      v.interest_art,
      v.visited_before,
      v.explanation_type,
      v.timeline_direction,
      buddhistHistoryKnowledgeDB,
      personaSummary,
      validationResult.confidence
    ];

    console.log("🧪 DB buddhist_history_knowledge =", buddhistHistoryKnowledgeDB);

    db.query(query, values, (err, result) => {
  if (err) {
    console.error("❌ MYSQL ERROR:");
    console.error("Code:", err.code);
    console.error("Message:", err.sqlMessage);

    return res.status(500).json({
      error: "DB insert failed",
      sqlMessage: err.sqlMessage,
      code: err.code
    });
  }

  res.json({
    visitor_id: result.insertId,
    confidence: validationResult.confidence,
    persona_summary: personaSummary
  });
});


  } catch (err) {
    console.error("🔥 ERROR:", err);
    res.status(500).json({
      error: "Persona generation failed",
      details: err.message
    });
  }
});





const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
