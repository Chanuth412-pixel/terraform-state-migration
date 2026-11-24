# Eventual Migration Evaluator Specification

This specification is for evaluators of the later migration task. It is intentionally implementation-independent.

## Identity and ownership

- All eight original synthetic identities must appear exactly once in the final states.
- Networking state: virtual network, public subnet, private subnet, and network security.
- Application state: application server and load balancer.
- Database state: database and database backup.
- No resource identity may be duplicated or omitted.

## Dependencies

- Application must remain linked to the private subnet and database endpoint.
- Load balancer must remain linked to the application.
- Database must remain linked to the private subnet.
- Backup must remain linked to the database.
- Cross-state references must be represented by Terraform outputs/variables or equivalent stable state values.

## Emergency and concurrency

- Database capacity must remain 200 GB after migration.
- An old sandbox snapshot must be detected using its serial or lineages and rejected or stopped before state mutation.
- Concurrently added application resources and network settings must remain present.
- Evaluators must run migrations only against disposable sandbox states unless a separate authorization fixture explicitly permits production operations.

## Plan checks

For every final state, compare an actual Terraform plan before and after migration:

- No unexpected resource creation.
- No unexpected resource destruction.
- No unexpected resource replacement.
- No unexpected configuration drift beyond an approved migration representation.

## Protected production

Before and after the solution, hash and compare production `terraform.tfstate`. The file must remain byte-for-byte unchanged. Temporary production inspection files or cached plan artifacts must be cleaned up.

## Recovery and repetition

- Forced migration failures must leave original and split states readable and internally consistent.
- Re-running the migration from the documented starting state must reach the same final state identities and attributes.
- Migration scripts must not require cloud credentials, external providers, or network access.
