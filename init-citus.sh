#!/bin/bash
set -e

echo "Adding Citus worker nodes..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  SELECT citus_add_node('citus_worker_1', 5432);
  SELECT citus_add_node('citus_worker_2', 5432);
  SELECT citus_add_node('citus_worker_3', 5432);
EOSQL

echo "Citus setup complete!"