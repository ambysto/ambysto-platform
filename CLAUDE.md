# ambysto-platform: Polar products and checkout links for the Ambysto Pro Suite

## What it is
`products.json`, one provisioning script and `POLAR_SETUP.md`. No application code yet. This repo is public: write everything as public (no private paths, host names, ticket ids or tokens).

## Verify
- `bash -n scripts/polar-provision.sh` and `jq . products.json`
- `scripts/polar-provision.sh --dry-run` prints every product with its id and link and creates nothing (needs a real `.env`; not run in CI).

## HARD: the main session does it directly, then an independent reviewer
- Anything that touches money or secrets: prices in `products.json`, the script's create calls, token handling, any webhook or checkout code. A token never appears in the repo, in output or in a commit.
- Licence keys: the owner makes them on the Mac. No code here issues, stores or sends a key.

## MEDIUM: builder builds, reviewer reviews
- Script changes that do not create or change Polar objects; docs that change meaning.

## EASY: no review
- Wording in README and `POLAR_SETUP.md`.

## Rules
- Contribute only as Ambysto: author `Ambysto`, no `Co-Authored-By` trailer, no "Generated with" line in PRs. `gh api user --jq .login` must print `ambysto` before the first push of a session; do not change the active gh account.
- Branches use a short slug; no push to `main` after the first commit. Do not merge without being asked.
- The script never edits prices, archives or deletes. Price changes happen in the Polar dashboard, by the owner.
- Production and sandbox are separate Polar environments; `POLAR_SERVER` picks one.
