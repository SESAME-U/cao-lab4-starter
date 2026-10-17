# Lab 4 submission

Fill in every line marked `ANSWER:` (one to three sentences each). Write the answer on the same line, right after `ANSWER:`; for pasted output, add a short summary there and paste the output below. Push before the start of the week 7 session.

## Setup

- Path used (azure, or tests only if you have no working Azure subscription): ANSWER:

## Part A - remote state

1. After your first `make apply`, where is your state? Paste the output of `az storage blob list --account-name <your account> --container-name tfstate --auth-mode login --query "[].name" -o tsv`. Is there a `terraform.tfstate` in `infra/`?
   ANSWER:

## Part B - the module

2. Why does `azurerm_public_ip.this` use `count` and not `for_each`? What does `azurerm_public_ip.this[0]` refer to, and what does the module create when `public_ip = false`?
   ANSWER:

## Part C - many servers

3. Paste the lines of `make state` for web1. Why is `for_each` over a map safer than `count = 2` the day you remove web1?
   ANSWER:

4. Paste the output of `make output` and the first line returned by `curl` on web1. The VM keeps `version = "latest"` instead of using the version read by the data source: what would happen to your VMs the next time Canonical publishes a new build if it did? (Tests-only path: paste the summary of `make test` instead of the outputs and curl.)
   ANSWER:

## Part D - replace and workspaces

5. Paste the `Plan:` line of `terraform apply -replace=...` on web2. What happened to web1, and why?
   ANSWER:

6. In the workspace `stage`, what did `terraform plan` propose, and why does it not see the resources of `default`? Name the blob that would hold the `stage` state.
   ANSWER:

## Cleanup

- `make destroy` done, workspace `stage` deleted, resource group `rg-cao-lab4-...` gone (yes/no): ANSWER:
