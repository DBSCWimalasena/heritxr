export function normalizeVisitor(v) {
  return {
    ...v,
    language_level:
      v.language_level === "Intermediate" ? "Moderate" : v.language_level,

    visit_purpose:
      v.visit_purpose === "Educational" ? "Assignment/Study" : v.visit_purpose,

    explanation_type:
      v.explanation_type === "Detailed" ? "Long Detailed" : v.explanation_type,

    timeline_direction:
      v.timeline_direction === "Chronological"
        ? "Past to Present"
        : v.timeline_direction,

    interest_architecture:
      v.interest_architecture === 1 ? "High" : "Low",

    interest_history:
      v.interest_history === 1 ? "High" : "Low",

    interest_spirituality:
      v.interest_spirituality === 1 ? "High" : "Low",

    interest_art:
      v.interest_art === 1 ? "Medium" : "Low",
  };
}
