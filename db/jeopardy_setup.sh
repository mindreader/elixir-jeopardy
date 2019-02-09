#!/bin/bash

#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE jeopardy;
    CREATE USER jeopardy with password '$JEOPARDY_PASSWORD';
    GRANT ALL PRIVILEGES ON DATABASE jeopardy TO jeopardy;
EOSQL
