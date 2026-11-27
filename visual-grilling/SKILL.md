---
name: visual-grilling
description: Use with every grilling session. Draws each round of questions as a rendered board that shows the context before it asks, and reads the user's dictated answers.
---

# Visual grilling

Grilling decides what to ask. This skill decides how a round reaches the user, who reads it on screen and answers by voice. Each round goes out as a **board**, one rendered page with a **card** for every question. A card draws its **scene**, the part of the plan or system the decision touches, before it asks.

Run grilling as written, with two changes. The board replaces grilling's text format for questions. A board carries at most three cards, so a larger frontier goes out over several boards, the questions that unblock the most first.

Every round runs steps 1 to 3. Step 4 ends the session.

## 1. Read what the user said

The user's messages are dictated. A transcript is loose, wanders between cards, and mis-hears words, so "docs" arrives as "dogs". The first message is the brief. Later ones answer the last board.

- Match each part to a card and an option by sound and meaning. "Your pick" takes your recommendation.
- Treat an answer that fits no option as a new option of the user's.
- Settle what you are sure of. An answer you resolved by sound or inferred is settled as a guess. An answer you cannot place goes back on the next board as its own card.
- Write anything exact the user said aloud, such as a name, a number or a glossary term, the way you will use it, so they see the spelling.

Done when every card from the last board is settled, settled as a guess, or queued to be asked again.

## 2. Draw the board

Read [`sample-round.md`](sample-round.md) once per session. It is the content of a whole round. Write the new round as one self-contained page, `board.html` in a scratch directory, with the same parts top to bottom.

**Heard.** What you took from the user's last message, a line each in your own words, guesses marked. A line the user corrects reopens its decision.

**Map.** The design tree: decisions settled with their answers, the cards on this board, and the questions waiting, each with what it waits on. That is a card, a lookup still running, or the next board. Leave out a group with nothing in it.

**Cards.** Each has four parts in this order.

1. A title of a few words.
2. The scene. Draw what the user would otherwise have to open, scroll back for or remember, such as the flow with its gap, the code as it stands, the screen or the data. Label it with the real names and numbers you found, and mark the spot the decision touches.
3. The question, in one sentence.
4. The options, side by side where their drawings fit and stacked where they need the width. Draw each option as the change it makes to the scene and give its price in a line. Mark your pick with its reason, and mark an option the user proposed as theirs. Give each a **spoken name**: one everyday word that says what the option is, sounds unlike every other name on the board, and is not a number or a letter. When a question has no set options, draw your recommended answer alone.

A fact you found that undercuts the brief gets its own card, asked first. A card whose scene needs a lookup still running waits for a later board.

Design the board with [html-taste](../html-taste/SKILL.md) for this round's content. The user reads it once and answers aloud, so make each option's spoken name the largest word on its option, and say your pick with its reason, the user's proposal and each guess in words beside what they describe. Settle a layout on the session's first board and keep it, so the user finds each part in the same place every round. Words on the board are labels and captions of a sentence or two. A point that needs a paragraph still needs a drawing.

The user answers by dictating the next message, so the board has no inputs.

Done when the user could answer every card from the board alone, and every option has a name they can say.

## 3. Show it

Pass `board.html` to `html_preview` and fix anything that overflows or is hard to read. Preview again at 390 wide. A page taller than 2000 pixels loses its last card to the next board. Then pass the page to `html_render` with the measured height.

Keep the reply to one line carrying only what the board cannot show, such as a lookup still running. With nothing to add, a few words that the board is ready are enough. The questions stay on the board. Then wait for the answer.

When the host cannot render HTML inline, send the same parts as text in the same order, and draw each scene with the compact fallbacks from the show-me skill.

## 4. Close

When the frontier is empty, send a last board with Heard and the map, every decision settled with its answer, and no cards. Ask whether it is the shared understanding grilling requires before you act.
