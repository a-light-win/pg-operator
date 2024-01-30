# pg-operator

This is a Kubernetes operator for managing multiple databases in the same
PostgreSQL instance. It supports following features:

- Create a database and its owner in a PostgreSQL instance on demand.
- Migrate a database from old version to new version on demand.

All operation is done automatically by the operator. You just need to create
a label `pg-operator.a-light.win/pg-version=13` and a label
`pg-operator.a-light.win/db-secret=<secret_name>` on the
application that using the database. The operator will do the rest.

If the secret does not exist, the operator will create a secret with a random
password. You can find the password in the secret.
The secret should contain following keys:

```yaml
database: <database>
username: <username>
password: <password>
host: <host>
```

The secret also contains the labels `pg-operator.a-light.win/pg-version`.
If the pg_version in the secret is different from the label on the application,
It will trigger a migration. after the migration is done, the label on the
secret will be updated to the new version.

And additional label `pg-operator.a-light.win/retention/pg-version` and
`pg-operator.a-light.win/retention/expired-at` will be added to the secret.
The old database will be removed after the retention period is expired.
