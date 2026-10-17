.PHONY: help check bootstrap init init-local fmt validate plan apply output state test workspace destroy destroy-state clean

TF = terraform -chdir=infra
# The azurerm provider reads the subscription from this variable.
AZ_SUB = export ARM_SUBSCRIPTION_ID=$$(az account show --query id -o tsv) &&

help:
	@echo "make check          verify the toolbox"
	@echo "make bootstrap      create your state storage in Azure, write infra/backend.hcl (once)"
	@echo "make init           terraform init with the remote backend"
	@echo "make init-local     terraform init without backend (tests-only path)"
	@echo "make fmt            format the code (terraform fmt)"
	@echo "make validate       check the syntax (terraform validate)"
	@echo "make plan           show what would change in Azure"
	@echo "make apply          create or update the resources in Azure"
	@echo "make output         show the outputs"
	@echo "make state          list what Terraform manages (terraform state list)"
	@echo "make workspace      show the current workspace and the others"
	@echo "make test           run the autograder tests (no Azure needed)"
	@echo "make destroy        delete everything this lab created (do this before you leave)"
	@echo "make destroy-state  delete the state storage itself (end of week 7 only)"
	@echo
	@echo "Extra Terraform options go in ARGS, for example: make plan ARGS=\"-var-file=x.tfvars\""

check:
	@bash scripts/check.sh

bootstrap:
	@bash scripts/bootstrap-state.sh

init:
	@test -f infra/backend.hcl || { echo "No infra/backend.hcl: run make bootstrap first (tests-only path: make init-local)"; exit 1; }
	$(TF) init -backend-config=backend.hcl $(ARGS)

init-local:
	$(TF) init -backend=false

fmt:
	terraform fmt -recursive infra

validate:
	$(TF) validate -no-tests

plan:
	@$(AZ_SUB) $(TF) plan $(ARGS)

apply:
	@$(AZ_SUB) $(TF) apply $(ARGS)

output:
	$(TF) output $(ARGS)

state:
	$(TF) state list

workspace:
	$(TF) workspace list

test:
	$(TF) test $(ARGS)

destroy:
	@$(AZ_SUB) $(TF) destroy $(ARGS)

destroy-state:
	@owner=$$(sed -n 's/^owner[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' infra/terraform.tfvars); \
	echo "This deletes rg-cao-tfstate-$$owner and every state file in it."; \
	read -r -p "Type the resource group name to confirm: " answer; \
	test "$$answer" = "rg-cao-tfstate-$$owner" && az group delete --name "$$answer" --yes && rm -f infra/backend.hcl

clean:
	rm -rf infra/.terraform
