M := ./bin/machines

.PHONY: help sync ls ping audit dead oci

help:
	@echo "make sync    regenerate ~/.ssh/config.d/machines from machines.yaml"
	@echo "make ls      list every machine in the inventory"
	@echo "make ping    TCP-check which machines are alive"
	@echo "make audit   ssh into each active machine and report what it runs"
	@echo "make dead    list decommissioned machines"
	@echo ""
	@echo "Once synced, connect with plain ssh: ssh oci / scp f hosto-prod:/tmp/"

sync:
	@$(M) sync

ls:
	@$(M) ls

ping:
	@$(M) ping

audit:
	@$(M) audit

dead:
	@$(M) ls --status dead

# kept for muscle memory; `ssh oci` does the same thing after `make sync`
oci:
	@ssh oci
