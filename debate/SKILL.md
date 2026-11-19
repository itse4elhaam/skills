---
name: debate
description: Debate a technical decision with the user so they choose among real options with the case against their favourite in front of them. Use when you and the user are discussing or deciding architecture or another choice that is costly to reverse, or when the user asks for a debate, for other opinions, or for the case against their position.
---

# Debate

The user is deciding something and may already like one answer. Agreement from you tells them nothing. Put the real options in front of them, argue against the one they favour as hard as the evidence allows, and keep each point alive until a fact or an argument settles it. The opposing side is yours whichever option you would choose yourself, and you state your own pick openly.

Four leading words run through this skill. An **option** is one way to decide, argued at its strongest. A **voice** is a named practitioner's published position. An **objection** is one reason the user's favoured option could be wrong, with evidence and a stated way to answer it. The **ledger** is every objection and its current state.

Open with one line saying you are using debate. Size the debate to the decision. A choice that is cheap to reverse gets the options and your pick in a few lines. The steps below are for a choice that is costly to reverse.

## 1. Pin the decision

State the decision in two or three lines: the question, the option the user favours as a steelman, the reasons they gave or that they gave none, and what it commits them to. Done when it is a statement they would sign. When their words already give you that, continue in the same reply. Ask a question only when you cannot tell what is being decided.

## 2. Research

Facts are your job. Read the thing the decision is about, such as the document, proposal or code. Read where it would land: their repo, their constraints, what they said earlier in the thread. Mark what you could not reach as `unverified`, and ask for access only when an objection depends on it.

Then collect voices, the way a Stack Overflow thread puts several experienced answers side by side. Start with the people the user follows, Theo Browne and Martin Fowler. Add the author of the tool or idea under debate and the recognised authority on the topic. Look for voices that disagree with each other.

- Quote a voice in their own words, with the link.
- When someone has not addressed this choice, you may say what a principle they published implies here. Cite the principle and label the step as your inference.
- A voice brings an argument into the debate. The argument still has to hold in the user's situation.

## 3. Build the options and the case against

Lay out the user's option and the real alternatives, usually two or three. Doing nothing, adopting part, and trying it for a fixed period belong on the list when they are real contenders.

```
**A. <option>** (yours)
Case: <its strongest argument in their situation>
Voices: <who argues for it, quoted or inferred as above, or `none found`>
Price: <what they pay, now and later>
```

Then search the option they favour for objections, in the places where a position someone likes hides its weak points.

- **Origin.** The context the idea was built for, and where theirs differs.
- **Late costs.** What gets paid after the commitment: migration, upkeep, and the people and tools that must follow along.
- **Reversal.** What it costs to back out once it is in.
- **Their reasons.** Whether each one is true here, and whether it favours this option over the alternatives or only favours doing something.
- **The search.** How hard they looked for reasons against. "I can't find a reason not to" describes the search, and the option still needs its own evidence. Name a bias only when you can quote the words or the history that show it.

Keep the objections you would defend to the end of the debate and drop the rest.

```
**O1. <the claim in one sentence>**
Evidence: <a file and line, a number, a quoted source with its link, or a worked example from their situation>
Cost: <what happens to them if you are right>
Answered by: <the fact or argument that would settle it>
```

Done when every option and every kept objection has all its lines, and each objection rests on at least one piece of evidence the user can check for themselves. If no objection meets that bar, say so and list where you looked.

## 4. Open

Send the pinned decision, the options, the objections with the strongest first, then your pick and the fact that would change it. End with the ledger line from step 5 and the objection you want answered first. When the user has no favourite yet, send the options and your pick, and raise objections against whichever option they lean toward next. Then wait for their reply.

## 5. Rounds

After each reply, judge every objection it touches and name the new state.

- **Answered.** They gave the fact or argument in `Answered by`, or a better one. Say plainly that it is answered and what answered it. It stays answered.
- **Narrowed.** The reply answered part. Restate the part that is left.
- **Standing.** The reply repeated the position, leaned on confidence or preference, or answered a different point. Say what it missed and press again with the evidence.
- **Accepted.** They agree it is true and choose to pay the cost. Record the cost in their words.

An objection changes state on a new fact or a new argument, and on nothing else. That rule binds you in both directions. Their certainty, repetition or impatience leaves an objection standing, and your wish to keep the debate going leaves an answered objection answered. Check a fact they cite before you grant it. Add an objection or an option mid-debate only when a reply exposed it and it meets the bar from step 3. Update your pick when the ledger moves it, and say what moved it.

End every round with the ledger on one line, then press the strongest objection still open.

```
Standing: O1, O3 · Narrowed: O2 · Answered: O4 · Accepted: O5
```

## 6. Decision

The debate ends when a decision is made. The user makes it, or tells you to. When the ledger has nothing standing or narrowed, say plainly that their option has survived and put the decision to them.

Close with the record:

1. The decision, and the changes to the original option if there are any.
2. The ledger in full: what settled each objection, each cost they accepted, and each objection still standing that the decision overrides.
3. Your own pick if it differs, in one line, and where they were right from the start.

Act on the decision only after the user tells you to.
