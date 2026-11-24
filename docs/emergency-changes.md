# Emergency Database Capacity Change

During an incident, the Database Platform team increased the synthetic orders database from 100 GB to 200 GB. This change was applied with Terraform:

```bash
terraform apply -auto-approve -input=false -var="database_capacity_gb=200"
```

The change is legitimate and must be preserved during any state migration. The checked-in variable default remains `100` GB; this is intentional and represents the pre-incident configuration. Blindly applying the original default to production would introduce an incorrect capacity downgrade.

Migration work must read the current state and carry a capacity of `200` into the database-owned final state. After migration, plans must not show an unexplained database downgrade unless an approved separate change has been made.

Reproduce this change with `bash scripts/emergency-change.sh`. `bash scripts/reset.sh` reproduces the complete benchmark starting state.