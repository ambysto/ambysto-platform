#!/usr/bin/env bash
# Idempotent: makes sure every product in products.json exists on Polar with one checkout link.
# Existing products and links are never changed (no price edits, no deletes). Prints a table, never the token.
# Usage: scripts/polar-provision.sh [--dry-run]   (needs curl and jq; reads POLAR_ACCESS_TOKEN from .env)
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
dry=0; [ "${1:-}" = "--dry-run" ] && dry=1
set -a; . "$root/.env"; set +a
[ -n "${POLAR_ACCESS_TOKEN:-}" ] || { echo "POLAR_ACCESS_TOKEN is empty in .env" >&2; exit 1; }
case "${POLAR_SERVER:-production}" in
  production) api=https://api.polar.sh ;;
  sandbox) api=https://sandbox-api.polar.sh ;;
  *) echo "POLAR_SERVER must be production or sandbox" >&2; exit 1 ;;
esac
call() { # method path [json]
  curl -fsSL -X "$1" "$api$2" -H "Authorization: Bearer $POLAR_ACCESS_TOKEN" -H "Content-Type: application/json" ${3:+-d "$3"}
}
products=$(call GET "/v1/products/?limit=100&is_archived=false")
links=$(call GET "/v1/checkout-links/?limit=100")
[ "$(jq -r '.pagination.max_page // 1' <<<"$products")" -le 1 ] && [ "$(jq -r '.pagination.max_page // 1' <<<"$links")" -le 1 ] || { echo "more than 100 products or links: add pagination first" >&2; exit 1; }
printf '| Product | Price | Product id | Checkout link |\n|---|---|---|---|\n'
jq -c '.[]' "$root/products.json" | while read -r p; do
  name=$(jq -r .name <<<"$p"); amount=$(jq -r .amount <<<"$p")
  id=$(jq -r --arg n "$name" '[.items[]|select(.name==$n)][0].id // empty' <<<"$products")
  if [ -z "$id" ]; then
    if [ $dry = 1 ]; then echo "| $name | would create | - | - |"; continue; fi
    body=$(jq -c '{name,description,recurring_interval:null,prices:[{amount_type:"fixed",price_amount:.amount,price_currency:"usd"}]}' <<<"$p")
    id=$(call POST /v1/products/ "$body" | jq -r .id)
  fi
  url=$(jq -r --arg id "$id" '[.items[]|select(any(.products[]?; .id==$id))][0].url // empty' <<<"$links")
  if [ -z "$url" ]; then
    if [ $dry = 1 ]; then echo "| $name | $amount | $id | would create link |"; continue; fi
    url=$(call POST /v1/checkout-links/ "$(jq -nc --arg id "$id" --arg l "$name" '{payment_processor:"stripe",products:[$id],label:$l}')" | jq -r .url)
  fi
  printf '| %s | %s | `%s` | %s |\n' "$name" "$(awk -v a="$amount" 'BEGIN{printf "$%.2f", a/100}')" "$id" "$url"
done
