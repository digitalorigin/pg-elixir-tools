# Health checks

When doing various daily deploys you want to make sure that your instance starts receiving requests
when once it's ready, to prevent failing requests. This section is responsible of defining a
behaviour for this requests and provides default checks.

## SQL Health check

The SQL healthchecks verifies that the instance is able to communicate with the SQL database.
