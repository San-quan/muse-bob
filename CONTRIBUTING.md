# Contributing

Thank you for wanting to contribute!

- Setup:
  1. Node 18+
  2. npm ci
  3. Create a branch: git checkout -b fix/your-thing
- Tests:
  - npm test
- Secrets:
  - To run wrangler publish dry-run, add `CF_API_TOKEN` in Settings  Secrets  Actions.
- CI:
  - The workflow will run lint, test and npm audit.
