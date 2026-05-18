# Guacamole PostgreSQL Init

Before the first `docker-compose up`, generate the Guacamole schema SQL and place it here:

```bash
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgresql > postgres-init/initdb.sql
```

Then start the stack:

```bash
docker-compose up -d
```

The `postgres-init/` folder is mounted into the Postgres container as `/docker-entrypoint-initdb.d/`, so the SQL runs automatically on the very first startup.

**Default Guacamole credentials:** `guacadmin` / `guacadmin`  
Change the password immediately after first login via Settings → Users.

After logging in, add an RDP connection:
- **Protocol:** RDP
- **Hostname:** `desktop`
- **Port:** `3389`
- **Username:** `abc` (or `root`)
- **Password:** `abc`  (the user password set in the Dockerfile)
