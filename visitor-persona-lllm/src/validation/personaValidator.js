/**
 * Persona Validation Algorithm
 * Returns a confidence score between 0 and 1
 */

export function validatePersona(visitor, summary) {
  let score = 0;
  let totalChecks = 0;

  const text = summary.toLowerCase();

  // 1. Age group mentioned
  totalChecks++;
  if (text.includes(visitor.age_group.replace("-", " "))) score++;

  // 2. Visit purpose reflected
  totalChecks++;
  if (text.includes(visitor.visit_purpose.toLowerCase())) score++;

  // 3. Architecture interest
  totalChecks++;
  if (
    visitor.interest_architecture === "High" &&
    text.includes("architecture")
  ) score++;

  // 4. History interest
  totalChecks++;
  if (
    visitor.interest_history === "High" &&
    text.includes("history")
  ) score++;

  // 5. Spirituality interest
  totalChecks++;
  if (
    visitor.interest_spirituality === "High" &&
    text.includes("spiritual")
  ) score++;

  // 6. Language level consideration
  totalChecks++;
  if (text.includes(visitor.language_level.toLowerCase())) score++;

  // 7. First-time or returning visitor
  totalChecks++;
  if (
    visitor.visited_before === 0 &&
    text.includes("first")
  ) score++;

  const confidence = score / totalChecks;

  return {
    confidence,
    passed: confidence >= 0.7
  };
}
