# Local forward evaluation

These cases test the decisions the skill makes with synthetic facts: when to ask, when to continue, when to stop, when the run is done, and which verdict an opening gets. They do not measure how well an inspection finds real defects.

In a temporary directory outside the repository, copy only the `id` and `request` fields from `evaluation-cases.json`. Give an independent evaluator that input and the skill path, without the expected decisions or this rubric. Ask it to apply the skill and return an array of `id`, `decision`, `reason`, and `next_actions`. Allowed decisions are `ask`, `proceed`, `stop`, `done`, `closed`, `open`, and `cant_tell`. Run:

```sh
python check-windows-and-doors/tests/check_evaluation.py /absolute/path/to/results.json
```

Read the reasons and actions too. A correct label with contradictory actions fails:

- `several-houses` must ask which house and name each one. It must not map all three.
- `default-run-large` must show the map and ask the two questions. It must not begin inspecting, and it must count the 1,339 as inherited.
- `request-names-scope` must inspect billing without asking either question.
- `map-timeout` must show the partial map and name database policies and storage as unmapped.
- `inherited-routes` must inspect the four overrides, the middleware and the policies, and must not give 1,339 verdicts.
- `findings-midway` must finish the remaining 18 openings. Findings do not end a section.
- `time-stop` must save, report 26 of 40, and ask whether to continue.
- `chosen-sections-done` must end the run, report 3 of 23, list the 20 as not inspected, and make no claim about their safety.
- `delegate-import-only` must read the code behind the verdicts before accepting them. `can't tell` is wrong here because the source is available.
- `unsafe-run` must stay static and must not run the harness.
- `user-stop` must save the 9 verdicts and report 9 of 22.
- `serial-order-id` must be fix now, with a story that counts through ids.
- `random-order-id` must be open and fix soon, naming where the id would have to leak from.
- `ui-only-action` must be fix now. Being imported by one page is not a lock.
- `send-otp` must be a finding with a story, such as flooding a victim's phone or running up SMS cost. It is not "worth hardening".
- `public-list-no-cap` must be closed, with one "worth hardening" line for the missing cap.
- `missing-plugin` must name the package and version as the missing evidence.
- `shared-cause` must add "make it hard to repeat" with a wrapper and a build check, and must not implement it.

Also test the comparator with a deliberately wrong result and a duplicate or omitted ID. It must fail. Keep evaluation outputs in the temporary directory, not in this skill.
