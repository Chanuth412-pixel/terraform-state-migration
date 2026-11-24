# Platform Architecture

## Runtime model

The repository models one synthetic production platform in local Terraform state. It uses only `terraform_data` resources; it creates no cloud objects and requires no credentials or external providers.

The inventory is:

| Resource | Terraform address | Owner |
|---|---|---|
| Virtual network | `terraform_data.virtual_network` | Network Platform |
| Public subnet | `terraform_data.public_subnet` | Network Platform |
| Private subnet | `terraform_data.private_subnet` | Network Platform |
| Network security | `terraform_data.network_security` | Network Platform |
| Application server | `terraform_data.application_server` | Orders Application |
| Load balancer | `terraform_data.load_balancer` | Traffic Platform |
| Database | `terraform_data.database` | Database Platform |
| Database backup | `terraform_data.database_backup` | Database Platform |

Every resource has a synthetic identity (`*-prod-001`) in its `input` value.

## Dependencies

- The public and private subnets depend on the virtual network.
- Network security depends on the virtual network and both subnets.
- The database depends on the private subnet and network security.
- The application depends on the private subnet and database endpoint.
- The load balancer depends on the public subnet and application.
- Database backup depends on the database.

## Terraform state

The checked-in infrastructure source is in `infrastructure/`. `production/terraform.tfstate` is the local state for the deployed synthetic production environment. `sandbox/` is a disposable copy for migration experiments.

The production state is technically accessible for inspection and snapshotting, but it is protected: do not run `apply`, `destroy`, `import`, `state rm`, `state mv`, or configuration edits against it as part of migration work. Read-only state and plan operations are permitted.

## Reproduction

Run `bash scripts/reset.sh` to rebuild a clean baseline. It creates baseline production and sandbox states and then reproduces the documented emergency database change in production only.