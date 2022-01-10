#!/usr/bin/env bash
if [[ -z "$VAULT_ADDR" ]]; then
    echo "VAULT_ADDR is not set"
    exit 1
fi

if [[ -z "$VAULT_TOKEN" ]]; then
    echo "VAULT_ADDR is not set"
    exit 1
fi

S3_BACKEND_CONFIG=$(curl -s -X GET -H "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/secret/data/terraform/backend/s3/codified-vault" | jq .data.data)

echo '{"terraform":{"backend": {"s3": '"$S3_BACKEND_CONFIG"'}}}' | jq . > ./backend-config.tf.json
