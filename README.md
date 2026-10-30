# ambysto-platform

Payments setup for the Ambysto Pro Suite on [Polar](https://polar.sh): one product per app and one Suite product, each with a Polar-hosted checkout link.

- `products.json`: the catalog (name, price in cents, description). Apps $19.99, Suite $39 (launch price; change it in the Polar dashboard when the launch ends).
- `scripts/polar-provision.sh [--dry-run]`: idempotent. Creates what is missing, never edits or deletes, prints the table of product ids and checkout links.
- `scripts/stripe-provision.sh [--dry-run]`: the same for Stripe (restricted key in `.env`), Payment Links by `metadata.key`.
- `POLAR_SETUP.md`, `STRIPE_SETUP.md`: what exists now.
- `.env.example`: key names. Copy to `.env` (gitignored) and put the organization access token there yourself.

Needs `curl` and `jq`. The token needs the products and checkouts scopes (read and write) and must be made in the production environment.

Licence keys are not issued here. Licence: Apache-2.0.
