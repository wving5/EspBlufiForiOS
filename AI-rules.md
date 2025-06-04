Copilot AI must conform to the following rules:

# General Coding Rules:
1. ALL changes MUST be based on current codebase with respect
2. MUST keep code clean, decoupled, well-structured
3. MUST keep an eye on thread safety, especially on critial path
4. MUST keep an eye on retain cycle e.g. implicitly catched variable
5. be EXTREMLY CAREFUL when you remove/refine old business logic, double check to ensure origin usecases get FULL covered with new approach
6. ALWAYS add logs to async action dispatch / service calling for debugging purpose

# Task Exectution Rules:
1. ALWAYS show the plan in detail BEFORE coding and ask me to REVIEW
2. ALWAYS break the plan/changes into SMALLER sub-steps
3. prefer expressive emoji for state enhancement, like ❌ for error, ✅ for success/done, ⭕️ for TBD

# Extra rules for AI agent mode ONLY:
1. agent should AWALYS skip build project unless user explict ask it to do that