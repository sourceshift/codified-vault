# Codified Vault

[Codify Management of Vault Using Terraform](https://learn.hashicorp.com/tutorials/vault/codify-mgmt-oss?in=vault/operations)

## Prerequisites

* [Terraform](https://www.terraform.io/), Make sure the [Terraform Binary](https://www.terraform.io/downloads) is in your PATH.

## How to Run

* Populate Backend Configuration in the Terraform File `backend-config.tf.json`.

```json
{
  "terraform": {
    "backend": {
      "s3": {
        "access_key": "SFBHSBHJBY46FHSJ",
        "bucket": "bucket-name",
        "endpoint": "us-east-1.linodeobjects.com",
        "key": "codified_vault/main.tfstate",
        "region": "us-east-1",
        "secret_key": "sfhaKJHKJHFKSjkhsfksafkjHJKHKH",
        "skip_credentials_validation": "true"
      }
    }
  }
}
```

* (*Optional*) If the backend is s3 and the credentials and configuration are present in any other vault in following path `$VAULT_ADDR/v1/secret/data/terraform/backend/s3/codified-vault` then you can Generate the Terraform File using the following command.

```bash
export VAULT_ADDR=https://addr
export VAULT_TOKEN=token
./get-terraform-file.sh
unset VAULT_ADDR
unset VAULT_TOKEN
```

Initiate the Terraform State.

```bash
terraform init -input=false -reconfigure -upgrade
```

* Populate the following variables in the `.secret.all.json`. Vault Token with All the Permissions Required for the Operation. Vault api address.

```json
{
    "VAULT_ADDR": "https://vault.example.com:8200",
    "VAULT_TOKEN": "s.xxxxxxxxxxxxxx"
}
```

Make changes and plan the changes with `terraform plan`.

```bash
terraform plan -input=false -var-file=".secret.all.json" -out="./tfplan"
```

Apply the changes with `terraform apply`.

```bash
terraform apply "./tfplan"
```

## License

MIT
