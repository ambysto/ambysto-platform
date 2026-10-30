#!/usr/bin/env bash
# Idempotent: makes sure every product in products.json exists on Stripe with one price and one Payment Link.
# Matches by metadata key (not by name). Existing objects are never changed, archived or deleted. Prints a table, never the key.
# Usage: scripts/stripe-provision.sh [--dry-run]   (needs curl and jq; reads STRIPE_SECRET_KEY from .env)
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
dry=0; [ "${1:-}" = "--dry-run" ] && dry=1
set -a; . "$root/.env"; set +a
case "${STRIPE_SECRET_KEY:-}" in
  rk_live_*|rk_test_*) ;;
  "") echo "STRIPE_SECRET_KEY is empty in .env" >&2; exit 1 ;;
  *) echo "STRIPE_SECRET_KEY must be a restricted key (rk_live_ or rk_test_)" >&2; exit 1 ;;
esac
mode=live; case "$STRIPE_SECRET_KEY" in rk_test_*) mode=test ;; esac
api=https://api.stripe.com
# The key goes to curl through a config on a pipe, so it is not on the command line (/proc/*/cmdline).
auth() { printf 'user = "%s:"\n' "$STRIPE_SECRET_KEY"; }
get() { curl --fail-with-body -sSL -G "$api$1" -K <(auth) "${@:2}"; }
post() { # path idempotency-key curl-data-args...
  local path=$1 idem=$2; shift 2
  # Fixed idempotency keys: within 24h Stripe replays the first result, even if the product was archived since.
  curl --fail-with-body -sSL -X POST "$api$path" -K <(auth) -H "Idempotency-Key: $idem" "$@"
}
products=$(get /v1/products -d limit=100 -d active=true)
links=$(get /v1/payment_links -d limit=100 -d active=true)
# Matching reads one page only; refuse to run where a match could be missed and a duplicate created.
[ "$(jq -r '.has_more' <<<"$products")" = false ] && [ "$(jq -r '.has_more' <<<"$links")" = false ] || { echo "more than 100 active products or links: add pagination first" >&2; exit 1; }
usd() { LC_ALL=C awk -v a="$1" 'BEGIN{printf "$%.2f", a/100}'; }
echo "Stripe mode: $mode"
printf '| Product | Price | Product id | Price id | Payment link |\n|---|---|---|---|---|\n'
jq -c '.[]' "$root/products.json" | while read -r p; do
  key=$(jq -r .key <<<"$p"); name=$(jq -r .name <<<"$p"); amount=$(jq -r .amount <<<"$p"); desc=$(jq -r .description <<<"$p")
  prod=$(jq -c --arg k "$key" '[.data[]|select(.metadata.key==$k)][0] // empty' <<<"$products")
  if [ -z "$prod" ]; then
    if [ $dry = 1 ]; then echo "| $name | $(usd "$amount") | would create | - | - |"; continue; fi
    prod=$(post /v1/products "ambysto-platform-$mode-product-$key" \
      --data-urlencode "name=$name" --data-urlencode "description=$desc" \
      -d "metadata[key]=$key" -d "default_price_data[unit_amount]=$amount" -d "default_price_data[currency]=usd" \
      -d "expand[]=default_price" | jq -c .)
  fi
  pid=$(jq -r .id <<<"$prod")
  price=$(jq -r '(.default_price | if type=="object" then .id else . end) // empty' <<<"$prod")
  [ -n "$price" ] || { echo "product $pid ($name) has no default price; fix it in the dashboard" >&2; exit 1; }
  url=$(jq -r --arg k "$key" '[.data[]|select(.metadata.key==$k)][0].url // empty' <<<"$links")
  if [ -z "$url" ]; then
    if [ $dry = 1 ]; then echo "| $name | $(usd "$amount") | $pid | $price | would create link |"; continue; fi
    url=$(post /v1/payment_links "ambysto-platform-$mode-link-$key" \
      -d "line_items[0][price]=$price" -d "line_items[0][quantity]=1" -d "metadata[key]=$key" | jq -r .url)
  fi
  printf '| %s | %s | `%s` | `%s` | %s |\n' "$name" "$(usd "$amount")" "$pid" "$price" "$url"
done
