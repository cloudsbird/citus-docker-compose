# Citus Docker Compose

This project provides a Docker Compose setup for running a distributed PostgreSQL database using Citus, a PostgreSQL extension that transforms PostgreSQL into a distributed database. The setup includes a coordinator node, multiple worker nodes, and a PgCat connection pooler for efficient connection management.

## Architecture

The setup consists of the following components:

- **Citus Coordinator**: The main PostgreSQL node that manages the distributed database.
- **Citus Workers**: Three PostgreSQL worker nodes that store and process data in a distributed manner.
- **PgCat**: A connection pooler that provides efficient connection management to the Citus cluster.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd citus-docker-compose
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Check the status of the services:
   ```bash
   docker-compose ps
   ```

## Configuration

### Services

#### Citus Coordinator
- **Image**: `citusdata/citus:13.0.3-alpine`
- **Port**: `5555` (mapped to container port `5432`)
- **Resource Limits**:
  - CPU: 1.0 core (limit), 0.5 core (reservation)
  - Memory: 1GB (limit), 512MB (reservation)
- **Logging**: JSON format with 10MB max size and 3 rotated files

#### Citus Workers
- **Image**: `citusdata/citus:13.0.3-alpine`
- **Ports**:
  - Worker 1: `6001` (mapped to container port `5432`)
  - Worker 2: `6002` (mapped to container port `5432`)
  - Worker 3: `6003` (mapped to container port `5432`)
- **Resource Limits**:
  - CPU: 1.0 core (limit), 0.5 core (reservation)
  - Memory: 1GB (limit), 512MB (reservation)
- **Logging**: JSON format with 10MB max size and 3 rotated files

#### PgCat Connection Pooler
- **Image**: `ghcr.io/postgresml/pgcat:latest`
- **Port**: `5432` (mapped to container port `5432`)
- **Resource Limits**:
  - CPU: 0.5 core (limit)
  - Memory: 256MB (limit)

### Environment Variables

The following environment variables are configured for all PostgreSQL services:

- `POSTGRES_USER`: `postgres`
- `POSTGRES_PASSWORD`: `secret`
- `POSTGRES_DB`: `citus`

### Volumes

Persistent data is stored in the following Docker volumes:

- `citus_coordinator_data`: Data for the coordinator node
- `citus_worker_1_data`: Data for worker node 1
- `citus_worker_2_data`: Data for worker node 2
- `citus_worker_3_data`: Data for worker node 3

### Network

All services are connected to a custom bridge network named `citus-network`.

## Connecting to the Database

You can connect to the Citus cluster using the PgCat connection pooler on port `5432`:

```bash
psql -h localhost -p 5432 -U postgres -d citus
```

Alternatively, you can connect directly to the coordinator node on port `5555`:

```bash
psql -h localhost -p 5555 -U postgres -d citus
```

## Initialization

The `init-citus.sh` script is automatically executed when the coordinator node starts for the first time. It adds the worker nodes to the Citus cluster:

```bash
#!/bin/bash
set -e

echo "Adding Citus worker nodes..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  SELECT citus_add_node('citus_worker_1', 5432);
  SELECT citus_add_node('citus_worker_2', 5432);
  SELECT citus_add_node('citus_worker_3', 5432);
EOSQL

echo "Citus setup complete!"
```

## PgCat Configuration

The PgCat connection pooler is configured with the following settings in `pgcat.toml`:

```toml
[pgcat]
listen_addr = "0.0.0.0"
listen_port = 5432
verbose = true
log_level = "info"
log_format = "json"

[database.citus]
pool_size = 100
pool_mode = "transaction"
host = "citus_coordinator"
port = 5432
user = "postgres"
password = "secret"
database = "citus"
```

## Resource Management

All containers have resource limits configured to prevent excessive resource usage:

- **CPU Limits**: Each container is limited to a specific number of CPU cores.
- **Memory Limits**: Each container is limited to a specific amount of memory.
- **CPU Reservations**: Each container is guaranteed a minimum number of CPU cores.
- **Memory Reservations**: Each container is guaranteed a minimum amount of memory.

## Logging

All containers are configured with JSON logging with rotation:

- **Log Driver**: `json-file`
- **Max Size**: `10m` (10 megabytes)
- **Max Files**: `3` (rotated log files)

## Maintenance

### Stopping the Services

```bash
docker-compose down
```

### Removing Volumes (Warning: This will delete all data)

```bash
docker-compose down -v
```

### Viewing Logs

```bash
# View logs for all services
docker-compose logs

# View logs for a specific service
docker-compose logs citus-coordinator
```

## Troubleshooting

### Service Health Checks

The setup includes health checks for all PostgreSQL services. You can check the status of the services:

```bash
docker-compose ps
```

### Common Issues

1. **Connection Refused**: Ensure all services are running and healthy.
2. **Memory Issues**: Check if the containers are hitting their memory limits.
3. **CPU Issues**: Check if the containers are hitting their CPU limits.

## License

This project is open source and available under the MIT License.