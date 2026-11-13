# House style

Elhaam's own review comments, quoted from past PRs with project details removed. They show what he flags and how he says it: short, often a question, one link when it teaches, and praise for good patterns. Treat them as examples of the lenses, not rules. The repo's `AGENTS.md`, `CONTRIBUTING.md`, and lint config win when they disagree.

## Contents

- Earns its place
- Fits the codebase
- Reads like English
- Tests earn their place
- Public endpoint
- Whole flow
- Fix the cause once
- Risk and evidence
- Praise

## Earns its place

- "What's the purpose behind this?"
- On a lockfile change: "Please state a concrete reason for this."
- On a deleted guide: "This is a really important file for error handling, why was this removed?"
- "Cannot remove these without recreating them at the second place."
- "Some of these changes might require their own PRs, suggest accordingly."
- "Strange this is showing up. `rebase` against `dev`."
- "Avoid commenting code. Remove it if not required."

## Fits the codebase

- "There must be a helper for this."
- "There should be a `safeParse` function inside the codebase, if not create and re-use."
- "Instead of try catch nesting, replace these with tryCatch function, it exists in the codebase."
- "Don't we have a global fetcher that we can use?" Then, after a reason not to: "Extend and use the fetcher."
- "Where is this URL coming from, shouldn't this be defined as a constant?"
- "`220` is a magic number, should be defined better."
- "Doesn't follow the `I` format and isn't in the types.ts file."
- "If params are more than 2, always use object based ones with interfaces in types.ts."
- "Constants under an object."
- "We shouldn't have more than one ProductCard in the codebase; it can have variants, though. Should follow the Open/Closed principle."
- "Why are we first converting an array into a set and then into an array back? The idea is to create a generic function with a purpose to handle this, to make the code more obvious."

## Reads like English

- "Else not needed, guard clause can simplify this."
- "Ternaries are often a bad abstraction after a single level, consider extracting into a function."
- "Nested ternaries do not scale. Look for a better solution."
- "More nesting = less long-term maintainability."
- "The idea is to strive to make the code read like English with minimal cognitive effort through naming, reduced nesting and other things." (links refactoring.guru)
- "Write complete names."
- "What does cadence mean here? Can't we use a simpler word here?"
- "I have no idea what it does by looking at it?"
- "Instead of a switch condition, we can just use an object."
- "Whenever you see something adding complexity within a large component file: if it can be made generic, move it out and make it generic. Otherwise, create an in-file component."
- "I'd be tempted to abstract this into its own function; we shouldn't be seeing internal workings of how idempotency is ensured in the main function."

## Tests earn their place

- "Tests should be for testing real user experience, not implementation details." (links the testing trophy article)
- "This test can be deleted, it's testing implementation details."
- "This is a snapshot test I think and is testing implementation details."
- "E2E tests should really earn their place because they take time in the CI."
- "A normal CSS change doesn't warrant an e2e run."
- "Approved, ensure these changes are tested locally. VALID offers must not be stopped."

## Public endpoint

- "If a file is marked as 'use server' and a function is exported from that file, it's a public POST endpoint. Verify this as well."
- "This is insecure, as it allows anyone to obtain any user's OTP without authentication. Move this to make it an internal function."
- "This could leak any review regardless of whether it's approved to show to public or not. Only public ones should be shown."
- "How is the security on this being managed?"
- "Never use server actions for GET requests, change this to be an API endpoint instead."
- "All services should be marked as server only."
- "Try to think of 'use client' as islands. Always try to pinpoint the use of 'use client' to a smaller code block within the component and then extract it."
- "No reason for this to be use client."

## Whole flow

- "If one of these fails, all will. Ensure this is what you need."
- "Isn't there an earlier step at which we can choke this, since the idea is to disable the jobs completely if required? What happens when we add a new job?"
- "Not sure we need such aggressive revalidation since the products live in the codebase. If the codebase changes, the build is triggered and these are generated automatically."
- "Are we using redis for this or an in-memory thing?"
- "Do we need `select *` here?"
- "Shouldn't assume that the user has `en`."

## Fix the cause once

- "Check why biome didn't catch this."
- "There should be a linting rule for this, AI loves to add `use client`."
- "Same ternary issue, check if we can enforce this through linting."
- "Prefer guard clauses, add to AGENTS.md as well."
- "Create a specific locked function for creating this format and use it everywhere. Add this pattern to AGENTS.md as well."

## Risk and evidence

- "For changes like these, reliability and correctness > shipping speed."
- "Since this is an extremely sensitive change, I am not comfortable in merging this unless tested by multiple people."
- "Please include image/video to show your changes."
- "Ensure this looks good in the UI. What happens if some of the text is too large?"
- "This should've required backend changes as well but I can only see extraction of components. What am I missing?"

## Praise

- "Good pattern."
- "Good naming."
- "Good work with using `extends`."
- "This is a correct use of server actions."
