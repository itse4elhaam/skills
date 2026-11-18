# Evaluation cases

Run each case through a fresh agent that reads only `SKILL.md` and `CANON.md`, never this file. Then check the reply against the pass criteria. A control run without the skill shows what the skill changes. Observed results are from 18 November 2026.

## Case 1: Salman's team card

**Input**

> Write the bio line for Salman's team card on the About page of TrueDevs, a small software studio. Salman is the engineering manager. Facts: Salman obsesses over reliability. On Samsú, an Irish cabin-booking client, he built bounded retries, health checks with alert emails, and error logging. Another card on the same page, for Noman, reads: "Leads experience and UX. Not easy to satisfy, which is the point."

**Why the shipped line failed.** "Built the retries, health checks and alerts that keep Samsú's booking site steady. Assumes everything will break, then makes sure it breaks safely." It has no role line, unlike its sibling. It lists internals a visitor can't picture. "Steady" promises an outcome the facts don't support. It ends on a tidy reversal that sounds clever and shows nothing.

**Pass criteria**

- The role comes first, plainly, within a few words of Noman's 12-word card.
- One fact a client could picture, rather than retries or health checks named as such.
- Care for the reader shows, and Salman would be glad to share the line.
- No outcome promises such as "never goes down", "steady" or "before you notice", and nothing a reader could check that the facts don't support, including who receives the alert emails.
- It doesn't reuse Noman's device or punchline.
- The reply has options across at least three angles, a pick with reasons, and a runner-up.

**Observed**

- Control without the skill: "Leads engineering. Assumes something will break, and builds for the day it does." The same tidy reversal as the shipped line.
- With the skill: "Leads engineering. Taught an Irish cabin-booking site to email for help when it's unwell." Personification, a picture, true whoever is on the alert list. Two other runs picked "Taught a cabin-booking site to email him when it's unwell", which flagged the recipient as a `[NEED]`, and "Taught Samsú's cabin-booking site not to give up on the first try".

## Case 2: Hero headline and subline

Lough Cabins is a fictional fixture.

**Input**

> Lough Cabins: six timber cabins on a lake in County Leitrim, Ireland. Each cabin has a wood-fired hot tub. No Wi-Fi in the cabins, only in the main lodge. Two-night minimum. Guest reviews, verbatim: "We didn't look at our phones for three days." / "The hot tub at night with the stars out was the best bit." / "Easy to book, and Aoife answered every question within the hour." Aoife is the owner. Write the homepage hero headline and subline.

**Pass criteria**

- 6 to 10 headline options on distinct angles, including one built on a guest's exact words.
- The pick names something only Lough Cabins can say, such as the hot tubs on a Leitrim lake.
- The no-Wi-Fi fact is stated truthfully, with the lodge Wi-Fi mentioned, and never turned into an unconfirmed motive like "on purpose".
- A quoted review carries a `[NEED]` for the reviewer's name and consent.

**Observed with the skill.** Headline: "Six timber cabins on a Leitrim lake, each with a wood-fired hot tub". Subline: the Wi-Fi fact plus the "three days" review, with a `[NEED]` for the reviewer. The run rejected "No Wi-Fi in the cabins. That's the whole idea." on the truth gate.

## Case 3: Card declined at checkout

**Input**

> Same fixture. Write the error shown when a guest's card is declined at checkout. The booking system holds the cabin for 15 minutes after checkout starts. The bank gives no reason.

**Pass criteria**

- Says what happened without guessing the bank's reason or blaming the guest.
- Answers "have I lost the cabin?" with the hold, and doesn't claim a flat 15 minutes remain.
- Offers a next step the guest can take now.
- Plain tone with no joke, because money is involved.

**Observed with the skill.** "Your bank declined this card without giving a reason. We're holding your cabin for another {time left}. Try a different card, or call your bank and then try this one again."

## Case 4: Testimonial from a raw email

**Input**

> Same fixture. Turn this guest email from Ciarán into a homepage testimonial: "honestly we were a bit worried about no wifi because my partner works remote but after the first day neither of us cared at all, we went out on the kayaks every morning and the kids still talk about the hot tub. aoife left us a loaf of brown bread which was a lovely touch. would 100% come back"

**Pass criteria**

- Only Ciarán's words, compressed. No new claims.
- Keeps his before-state, the Wi-Fi worry, and his result.
- Details that would read as a promise, the kayaks and the bread, are cut or flagged for Aoife to confirm.
- Flags Ciarán's approval and credit line.

**Observed with the skill.** "We were a bit worried about no Wi-Fi because my partner works remote, but after the first day neither of us cared at all. The kids still talk about the hot tub." Flags for approval, credit line, kayaks and bread.
