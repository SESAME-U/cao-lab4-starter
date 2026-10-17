# Cloud Automation and Orchestration - Lab 4

SESAME University, Computer Engineering, ING5. Week 6: Terraform, part 2.

Lab 3 declared one web server in one folder, with its state in a local file. In this lab you turn the server into a reusable module, create several servers from one map with `for_each`, read data from Azure with a data source, move the state to Azure Storage, replace one server on purpose and look at a second environment with a workspace.

## Start

1. Open this repository in a Codespace, wait for `Toolbox ready`, run `make check`.
2. `az login --use-device-code`, copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars` and set `owner`.
3. `make bootstrap` (once), then `make init`.
4. Follow the Lab 4 handout.

No working Azure subscription: skip step 3, run `make init-local`, and use `make validate` and `make test` (see the handout, tests-only path).

## Files

| Path | What |
| --- | --- |
| `infra/versions.tf`, `infra/providers.tf` | given: versions, the `azurerm` backend, provider settings |
| `infra/main.tf` | given: resource group and network; yours: the data source and the module call |
| `infra/variables.tf` | given, except the validation of `vms` |
| `infra/outputs.tf` | four outputs built with `for` expressions |
| `infra/modules/web-vm/` | the module: `variables.tf` given, `main.tf` and `outputs.tf` yours |
| `infra/cloud-init.yaml` | given: installs nginx at first boot |
| `infra/tests/` | the autograder's tests: they run without Azure, with a mocked provider |
| `scripts/bootstrap-state.sh` | creates your state storage account and writes `infra/backend.hcl` |
| `SUBMISSION.md` | answers |

## Grading (10 points, autograded on every push)

| Check | Points |
| --- | --- |
| `terraform fmt`: the code is formatted | 1 |
| `terraform validate`: the configuration is valid | 1 |
| The module: resources, `count` on the public IP, outputs (`tests/module.tftest.hcl`) | 3 |
| The root: `for_each` over `var.vms`, data source, validation (`tests/root.tftest.hcl`) | 2 |
| Outputs built with `for` expressions (`tests/outputs.tftest.hcl`) | 1 |
| `SUBMISSION.md` complete | 2 |

The tests never touch Azure: they replace the azurerm provider with a mock. Run them yourself with `make test`.

**Before you leave:** `make destroy`, then stop your Codespace. Keep the state storage account: Workshop 2 in week 7 uses it.
