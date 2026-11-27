# Sample round: retrying webhooks

What one board says, in order. The look comes from html-taste and the content in front of you.

## Heard

- Retries live in the queue worker, because Redis is already there.
- Give up after 5 tries, then dead letter.
- Guess: the table is `webhook_attempts`. Spelled from speech.

## Map

- Settled: delivery is at least once. The queue worker owns retries. 5 attempts, then dead letter.
- This board: 1 Backoff, 2 Repeat deliveries.
- Waiting: alerting waits on 1. The replay tool waits on 2.

## 1. Backoff

Scene, a flow with the decision point marked:

`order.paid` event → `deliverWebhook()` at `jobs/webhooks.ts:41` → **5xx or timeout: logged, then dropped** (the decision) → the customer never hears.

Caption: 2.1% of deliveries failed last week. Most fell inside one 4 minute outage.

Question: How should the worker space out its five tries?

- **Double** (my pick): 1m → 2m → 4m → 8m. Price: an outage longer than 15 minutes still loses the event. Why: a blip retries within a minute and a 4 minute outage is covered.
- **Steady** (your proposal): 5m → 5m → 5m → 5m. Price: a one second blip waits five minutes for its first retry.
- **Instant**: 0s → 0s → 0s → 0s. Price: all five tries land on an endpoint that is still down.

## 2. Repeat deliveries

Scene, the code as it stands:

```ts
// jobs/webhooks.ts:44
await fetch(endpoint.url, {
  method: "POST",
  body: JSON.stringify(event),
})
```

Caption: a retry after a timeout can deliver the same event twice. Nothing in the request tells the customer.

Question: How does a customer spot a repeat?

- **Header** (my pick): add `headers: { "Idempotency-Key": event.id }`. Price: customers have to read the header, one docs page. Why: `event.id` is already stable across retries.
- **Nothing**: leave the request alone and write "deliveries may repeat" in the docs. Price: every customer builds their own check on the body.

Answer out loud. Say an option's name, "your pick", or your own idea.
