# Drawing the map

The map lists every opening in the house, groups them into sections, and tells the user where to look first and how long each choice takes. It is cheap on purpose. Read registrations, signatures and policies here, and leave handler bodies for the inspection.

## 1. List every opening

An opening is anything an outside caller can reach. List openings one per row, with no grouping yet.

| Where openings hide | What to read |
| --- | --- |
| HTTP routes | Route files and method exports, router registrations including chained calls such as `router.route(path).get(...).post(...)`, mount prefixes, rewrites, old API versions. |
| Server actions and RPC | Every exported `use server` function, procedure registrations, edge functions, database functions callable by a client role. |
| GraphQL and realtime | Queries, mutations, subscriptions, websocket message types and topics. |
| Direct data access | Tables, views and functions reachable from a client SDK, storage buckets, signed-URL issuers. These have no handler file, so read grants and policies. |
| Files and integrations | Upload and download handlers, webhook receivers, OAuth callbacks, redirects that take a caller-supplied URL. |
| Pages | Server-rendered pages and loaders that put data in the response. |
| Operational | Health, debug, admin and cron endpoints reachable over the network. |

Three rules keep the list finite:

- **Inbound only.** A job, query or outbound call is followed during the inspection of the opening that triggers it. It never gets a row. A cron endpoint reachable over HTTP is an opening. The job it starts is not.
- **Inherited openings are counted, not listed.** For each framework or platform, record one line with the number of openings it ships. A route the house overrides, extends or configures is the house's own code and gets a row.
- **Two sources must agree.** Compare what the file layout implies with what the registrations say, and explain any difference before moving on.

## 2. Form the sections

1. Give each opening a home by the main data it reads or writes. Openings on invoices and payments share a home.
2. Name each section for the product feature that owns that data, in the product's own words from its navigation and docs.
3. Put in the frame every opening that touches no feature's data or every feature's. The frame also holds the shared locks: middleware and its matchers, session handling, database policies and client roles, cross-origin settings, and secrets that reach the client bundle. Each inherited group gets its one line here.
4. When an opening serves a second section, keep its one home and note "also serves" beside it.
5. Split a section that holds more than 40 openings, by resource, such as billing/invoices and billing/refunds. The user may set a different limit.
6. Check that the section counts add up to the full list. An opening without a home goes to the frame.

## 3. Flag the usual suspects

Make one short pass and mark a flag wherever a row looks like one of these. A flag is a lead for the inspection. It is never a finding and never appears in a report as one.

- A handler that reads an ID from the request with no ownership check in sight.
- An exported server action or procedure with no check in its wrapper.
- An admin operation whose only visible gate is in the UI.
- A write that passes the request body through to the database.
- A sign-in, reset, invite, one-time-code or paid call (AI, SMS, email) with no limit in sight.
- A webhook with no signature verification.
- An upload with no type, size or path rule.
- A table or bucket reachable from the client with no policy, or a permissive one.
- A service-role key or other secret referenced from client code.
- A middleware matcher that skips some routes.
- A debug, cron or job endpoint with no credential check.
- A server-side fetch of a caller-supplied URL.

## 4. Rank the sections

Rank on three things, in this order of weight:

1. **Reach.** A stranger outranks a signed-in user, who outranks a privileged role, who outranks a machine caller.
2. **What it holds.** Money, personal data, credentials, admin powers, then other writes, then public reads.
3. **Flags.** More flags raise a section.

The frame ranks first whenever it holds shared locks, because every other section's verdicts lean on them. Give each section one line saying why it sits where it does.

## 5. Estimate the time

Give each section a time range. Start from one to two minutes per opening, so a 40-opening section is about 40 to 80 minutes. Once a section has been inspected, use its measured pace for the rest. Say beside the estimates which of the two they come from.

## 6. Save and show the map

Keep `.security/` out of version control by adding it to `.git/info/exclude`, since it describes holes that are not yet fixed.

`.security/map.md` holds:

- The house, commit, date, and section size limit.
- The roles found in the code and what each may do, for the user to correct.
- One line per inherited group with its count.
- The section table below.
- Under each section, its openings: ID, opening, source location, flags, also serves.

| Rank | Section | Openings | Reach | Holds | Flags | Time | Inspected |
| --- | --- | --- | --- | --- | --- | --- | --- |

`Inspected` is "no", "stale", "stopped at N of M", or the date and commit of a finished inspection. Show the same table in the chat.
