# Polar setup (production)

Organization `ambysto` (id `20b8a933-a985-49a6-bc14-c8828633147d`), dashboard https://polar.sh/dashboard/ambysto. This runs against the live production environment.

## What exists
Eight one-time products, each with one Polar checkout link (hosted by Polar; no app code, no webhook yet). Each app is $19.99; the Suite is $39 (launch price). When the launch ends, change the Suite price to $59 in the Polar dashboard.

| Product | Price | Product id | Checkout link |
|---|---|---|---|
| Ambysto Pro Suite | $39 | `17d223fe-aa80-4a35-9940-c17a9e0587f7` | https://buy.polar.sh/polar_cl_Yw2wRD0SQyi8FhEiMLf3M7e9SCxEI3zwmLKtQ3ku804 |
| Ambysto DevBox Pro | $19.99 | `9a205c30-63c0-4324-b283-1300558fda40` | https://buy.polar.sh/polar_cl_Wsw2hIFOqC6kdegpChl0B8yfim58iyhYcb34U2r8I5A |
| Ambysto Gate Pro | $19.99 | `79b6d5bf-1489-4759-a604-63319646183b` | https://buy.polar.sh/polar_cl_rnU73WGjiIrVT6VLqGy1zLtilHvq1zRopGXMY1uMRtL |
| Ambysto Lean Pro | $19.99 | `ff666960-5d9d-47c6-8fcd-a45f419bc281` | https://buy.polar.sh/polar_cl_E5cI8aN6LEMLSkD4MWIQ2B8ke53BsE6YkXS1Z2yA7yw |
| Ambysto Optimer Pro | $19.99 | `a159a78a-2c84-4f03-a647-32dad9b6830a` | https://buy.polar.sh/polar_cl_N6mmJO6QT9r2uLcb7iZldIMoXfYbFj3WjK44D2FQ6x4 |
| Ambysto Power Pro | $19.99 | `0693b4d7-6549-4ed6-b003-0a89f0742ed2` | https://buy.polar.sh/polar_cl_GhlXnpmarvFyuf0g3VKk4DArpRSuFUqvh1EWD0QDW8y |
| Ambysto Steady Pro | $19.99 | `c0ee5bbe-68be-4f10-a795-73477426275f` | https://buy.polar.sh/polar_cl_4ILO5uRLAIjT1dxQuM3Sq3c3mwCucZCbWJgAs2zIshb |
| Ambysto Tune Pro | $19.99 | `082599eb-2b7c-4512-a179-141f5c07d4c0` | https://buy.polar.sh/polar_cl_PIA0iirrL14skqrpSmHjfpNWE53fwUCnvm9sL3wbuV1 |

## Not done on purpose
- No checkout or webhook routes, no SDK: the links above need none. Regenerate this table with `scripts/polar-provision.sh`.
- Licence keys are not issued by Polar or by code; the owner makes them on the Mac. Product descriptions promise no delivery.
- No webhook endpoint registered. `POLAR_WEBHOOK_SECRET` in `.env` stays empty.
- Polar hosts the customer portal and emails customers a link to it.

## Env (names only, in the gitignored `.env`; see `.env.example`)
`POLAR_ACCESS_TOKEN`, `POLAR_WEBHOOK_SECRET`, `POLAR_SERVER`.

## Before wiring the links into the suite site
- [ ] Open each link once and check name, price and currency.
- [ ] Test with a 100% discount code (discounts API); a plain link cannot pre-apply it.
- [ ] Rotate the access token if it was ever shared outside `.env`.
