# Discovery and controls

Use the discovery cues that match the repository. Apply the control families to every operation; mark irrelevant checks with a reason. These are investigation prompts, not vulnerabilities to copy into a report.

## Discovery cues

| Area | Inspect |
| --- | --- |
| HTTP and framework routes | Route files, method exports, router/controller registration, mounting prefixes, middleware matchers, rewrites, old API versions, generated routes. |
| Server actions and RPC | Callable `use server` exports, action wrappers, tRPC/procedure registration, database function grants, edge functions. Distinguish internal helpers from client-callable exports. |
| GraphQL and realtime | Schema and resolvers, field resolvers, batching, subscriptions, websocket handshake and per-message/topic authorization. |
| Direct database and storage | Client SDK calls, exposed schemas/tables/views/functions, grants, RLS policies, service-role bypasses, bucket policies, signed URLs and expiry. |
| Files and integrations | Multipart parsing, upload destinations, download/export handlers, webhook ingress, callbacks, redirects, server-side fetches and imports. |
| Operational routes | Health/debug/admin endpoints, cron authentication, job enqueueing, queue consumers reachable through untrusted payloads, deployment manifests. |

Search broadly enough to find framework conventions, then follow actual registrations and callers. Inspect generated manifests if already available. Do not run a build merely to discover routes until its scripts and external effects have been checked.

## Control families

Use these keys in the coverage ledger.

| Key | Questions to resolve |
| --- | --- |
| AUTHN | Does the server verify sessions/tokens or service credentials, including relevant expiry, issuer, audience, signature, and revocation behavior? Are identity headers trusted only from a verified proxy? Are secrets kept out of client bundles and responses? |
| AUTHZ | Can this actor perform this action on this tenant, object, and field? Are user and tenant IDs derived from trusted identity or checked against membership? Do nested resources and bulk operations check every target? Do admin routes enforce privilege on the server? |
| INPUT | Is runtime validation applied before use? Check allowed fields, types, bounds, lengths, enums, numeric edge cases, duplicate parameters, coercion, null/missing values, and file/body sizes. Are sensitive write fields explicitly selected? |
| SINK | Are SQL values parameterized and dynamic identifiers allowlisted? Can query operators, shell arguments, templates, or file paths alter execution? Trace URL fetches through redirects and address resolution for access to private/internal destinations. Verify downstream responses before trusting them. |
| OUTPUT | Does serialization select only permitted fields? Check nested relations, errors, list totals, exports, logs, shared caches and cache keys, public storage, signed URLs, topic subscriptions, and server-rendered payloads. Verify scope before generating access links. Check context-appropriate encoding where data becomes browser markup or script, and safe response content types. |
| BOUNDS | Are list limits bounded on the server, including negative, zero, missing, and oversized values? Check cursor scope, expensive offsets, filter/sort/join cost, indexes, query timeout, GraphQL depth/complexity/batches, regex cost, decompression, file size, streaming, and memory use. Pagination alone does not bound all work. |
| ABUSE | Are request rates, concurrency, retries, queued work, and paid operations bounded at the appropriate identity/tenant/network layer? Can proxy headers or alternate routes bypass controls? Check storage growth, email/SMS/AI/API spending, account recovery and other sensitive business actions. Record unknown edge/WAF settings without inventing them. |
| INTEGRITY | Can callers set prices, roles, balances, status, or ownership? Are valid transitions checked? Can concurrent or repeated requests bypass quotas, double-charge, redeem twice, or overwrite another update? Trace transactions, uniqueness, idempotency scope, and ordering of external effects. |
| PROTOCOL | For cookie-authenticated changes, verify CSRF/origin controls and cookie settings in context. CORS is not authorization. For webhooks, verify signatures over the correct bytes before effects, freshness where required, event identity, replay handling, and duplicate behavior. Check upload content/path handling and download disposition. |

## Follow the effective database role

For direct database access, inspect grants and policies for reads and each mutation. Follow views and functions, including security-definer behavior and execution privileges. For application access, determine whether the actual client role bypasses policies. Do not assume RLS protects an admin/service connection. Distinguish migration definitions from proof that a live environment applied them; do not contact that environment to resolve the gap under local-only testing authority.

## Avoid false positives

- Authentication can be shared; prove its placement and reachability before alleging it is missing from a handler.
- Public content may intentionally be readable. Establish the intended data policy before labeling disclosure.
- Validation can live in a wrapper or parser. Verify its execution and rejection behavior before demanding duplicate checks.
- Parameterized values do not prove dynamic SQL identifiers are safe; raw SQL does not by itself prove injection.
- A process-local limiter may be insufficient across instances, but explain deployment assumptions instead of asserting a bypass without evidence.
- A source-level gap in deployment configuration remains a gap unless a reachable failure can be established.

## Further reference

Use the [OWASP API Security Top 10, 2023 edition](https://api-security.owasp.org/editions/2023/en/0x11-t10/) as an additional category cross-check, not as proof of a repository defect or a completeness certification. Consult official framework/provider documentation for the versions found in the project when specific behavior matters.
