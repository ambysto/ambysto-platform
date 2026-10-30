# Stripe setup (live)

Runs next to Polar ([POLAR_SETUP.md](POLAR_SETUP.md)), for comparison. Stripe is not the merchant of record: tax and invoicing are the owner's, and Stripe Tax is not enabled on these links. This ran against the live Stripe environment.

Eight one-time products, each with one USD price and one Payment Link (Stripe's hosted confirmation page, no app code, no webhook). Apps $19.99, Suite $39 (launch price; when the launch ends, create a new price in the Stripe dashboard and then make a new Payment Link for it or edit the link's line item: a Payment Link keeps selling the price it was created with, and the script does not notice). Regenerate this table with `scripts/stripe-provision.sh` (idempotent, matches by `metadata.key`).

| Product | Price | Product id | Price id | Payment link |
|---|---|---|---|---|
| Ambysto DevBox Pro | $19.99 | `prod_VXH4jJ8j05kIfu` | `price_1UWCWjDFA1jU87YZtzhFqOcz` | https://buy.stripe.com/aFa5kD5qW27C7GzcWK04800 |
| Ambysto Optimer Pro | $19.99 | `prod_VXH4HhDf3dcu11` | `price_1UWCWkDFA1jU87YZwTOf9xU0` | https://buy.stripe.com/6oUcN51aG13ygd5cWK04801 |
| Ambysto Power Pro | $19.99 | `prod_VXH4f8qlENifzn` | `price_1UWCWlDFA1jU87YZRI3fVt3p` | https://buy.stripe.com/6oUaEX9Hc6nS8KD3ma04802 |
| Ambysto Tune Pro | $19.99 | `prod_VXH4OxAueyNYlW` | `price_1UWCWmDFA1jU87YZuNW1yG0u` | https://buy.stripe.com/3cIeVdbPk5jOaSL1e204803 |
| Ambysto Gate Pro | $19.99 | `prod_VXH4WSdb1zazBI` | `price_1UWCWnDFA1jU87YZWRlcBS9s` | https://buy.stripe.com/bJeeVdg5A3bGe4X09Y04804 |
| Ambysto Lean Pro | $19.99 | `prod_VXH4SZNX7q06CB` | `price_1UWCWpDFA1jU87YZvIS1cLPh` | https://buy.stripe.com/4gMdR95qWbIc4uncWK04805 |
| Ambysto Steady Pro | $19.99 | `prod_VXH5NtBFlZVYot` | `price_1UWCWqDFA1jU87YZTE0A3Qsw` | https://buy.stripe.com/cNiaEX8D8h2w6Cvf4S04806 |
| Ambysto Pro Suite | $39.00 | `prod_VXH5SwneUy8rrN` | `price_1UWCWrDFA1jU87YZwidDnIy8` | https://buy.stripe.com/fZu6oH9Hc27Cgd5bSG04807 |

## Not done on purpose
- No webhook, no checkout code, no licence key delivery (the owner makes keys on the Mac).
- Links are not wired into the suite site.
- Stripe Tax is off.

## Env (names only, gitignored `.env`)
`STRIPE_SECRET_KEY`: a restricted key with write access to Products, Prices and Payment Links.

## Before wiring
- [ ] Open each link once; check name, price, currency.
- [ ] Decide on Stripe Tax and receipts.
- [ ] Revoke any key that was shared outside `.env`.
