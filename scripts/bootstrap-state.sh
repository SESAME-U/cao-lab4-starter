#!/usr/bin/env bash
# Lab 4, Part A: create the Azure Storage account that holds your Terraform
# state, and write infra/backend.hcl. Safe to re-run (idempotent).
#
# Why a script and not Terraform? The state storage must exist before
# "terraform init" can use it: Terraform cannot keep its own state in a
# storage account it has not created yet. Small bootstrap scripts like this
# one are the usual answer.
set -euo pipefail

tfvars="infra/terraform.tfvars"
location="${LOCATION:-westeurope}"

owner=$(sed -n 's/^owner[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' "$tfvars" 2>/dev/null || true)
if [[ -z "$owner" || "$owner" == "your-github-username" ]]; then
  echo "Set owner in $tfvars first (cp infra/terraform.tfvars.example infra/terraform.tfvars)." >&2
  exit 1
fi
az account show >/dev/null 2>&1 || { echo "Run az login --use-device-code first." >&2; exit 1; }

sub=$(az account show --query id -o tsv)
rg="rg-cao-tfstate-${owner}"
# Storage account names: 3 to 24 lowercase letters and digits, unique in all
# of Azure. A hash of your username and subscription keeps it stable.
sa="stcaotf$(printf '%s' "${owner}${sub}" | sha1sum | cut -c1-12)"

echo "==> Registering Microsoft.Storage (once per subscription)"
az provider register --namespace Microsoft.Storage --wait -o none

echo "==> Resource group $rg"
az group create --name "$rg" --location "$location" \
  --tags course=cao purpose=tfstate owner="$owner" -o none

echo "==> Storage account $sa"
if ! az storage account show --name "$sa" --resource-group "$rg" -o none 2>/dev/null; then
  az storage account create --name "$sa" --resource-group "$rg" --location "$location" \
    --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 \
    --allow-blob-public-access false --tags course=cao purpose=tfstate owner="$owner" -o none
fi

echo "==> Blob versioning on (an older state can be restored)"
az storage account blob-service-properties update --account-name "$sa" \
  --resource-group "$rg" --enable-versioning true -o none

echo "==> Container tfstate"
az storage container-rm create --storage-account "$sa" --resource-group "$rg" \
  --name tfstate -o none

echo "==> Giving you the Storage Blob Data Contributor role on $sa"
me=$(az ad signed-in-user show --query id -o tsv)
scope=$(az storage account show --name "$sa" --resource-group "$rg" --query id -o tsv)
if [[ -z "$(az role assignment list --assignee "$me" --role "Storage Blob Data Contributor" --scope "$scope" --query '[].id' -o tsv)" ]]; then
  az role assignment create --assignee-object-id "$me" --assignee-principal-type User \
    --role "Storage Blob Data Contributor" --scope "$scope" -o none
fi

echo "==> Waiting for the role to reach the storage service (can take a few minutes)"
for i in $(seq 1 30); do
  if az storage blob list --account-name "$sa" --container-name tfstate --auth-mode login -o none 2>/dev/null; then
    break
  fi
  if [[ $i -eq 30 ]]; then
    echo "The role is not active yet. Wait two minutes and run make bootstrap again." >&2
    exit 1
  fi
  sleep 10
done

cat > infra/backend.hcl <<HCL
# Written by scripts/bootstrap-state.sh. Ignored by Git.
resource_group_name  = "$rg"
storage_account_name = "$sa"
container_name       = "tfstate"
key                  = "lab4.tfstate"
HCL

echo
echo "Remote state ready. infra/backend.hcl:"
cat infra/backend.hcl
echo
echo "Next: make init"
