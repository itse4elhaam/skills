# Check windows and doors

The vocabulary of the security inspection skill: an occasional, extensive inspection of everything an application exposes to outside callers.

## Language

**House**:
One deployable application under inspection. A folder that holds several applications holds several houses, and scoping picks which one.
_Avoid_: System, target, codebase

**Section**:
One product feature of the house, such as billing or messaging, together with every opening that belongs to it.
_Avoid_: Area, module, batch, partition

**Frame**:
The one section that holds what no product feature owns: shared locks such as middleware and database policies, and openings that serve the whole house.
_Avoid_: Infrastructure, shared, cross-cutting, misc

**Map**:
The visual overview of the house showing every section, its openings, its rank, and whether it has been inspected. The user chooses what to inspect from it.
_Avoid_: Inventory, ledger, report

**Flag**:
A quick sign, noticed while drawing the map, that an opening looks like a commonly left-open one. A flag is a lead for an inspection and never a finding.
_Avoid_: Issue, hit, warning

**Opening**:
Anything an outside caller can use to read data, change state, or make the house do work. Doors and windows are both openings; the skill does not distinguish them.
_Avoid_: Operation, endpoint, entry point, surface

**Lock**:
A check that the server provably runs before an opening reads, changes, or spends anything. An opening is public until a lock is proven; a hidden URL, an unguessable ID, or "only our UI calls it" is not a lock.
_Avoid_: Control, guard, protection

**Verdict**:
The result of inspecting one opening: `closed`, `open`, or `can't tell`, each with the source lines that prove it. An `open` verdict is a finding.
_Avoid_: Status, coverage state, review status

**Break-in story**:
The attacker's-eye account that every finding carries: who they are, what they must know or guess, the steps they take, and what they walk away with. The attacker is a person or an agent.
_Avoid_: Exploit, proof of concept, attack scenario

**Inherited opening**:
An opening that a framework or platform ships and the house's own code does not define. It is counted on the map and not inspected; the house's configuration and overrides of it are the house's own code.
_Avoid_: Native route, framework route, generated route

**Home**:
The single section an opening belongs to, decided by the main data it touches. An opening has exactly one home and may be shown as also serving other sections.
_Avoid_: Owner, assignment

**Scoping**:
The few multiple-choice questions the user answers: which house, asked before the map when a folder holds several, then what matters most and how much time, asked from the finished map.
_Avoid_: Interview, discovery, kickoff

**Inspection**:
A deep check of every opening in one section. It is occasional and extensive, not a routine or per-change review.
_Avoid_: Pass, scan, sweep
