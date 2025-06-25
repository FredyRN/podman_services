#!/bin/bash
set -e

# Use environment variables with defaults if not set
: "${POSTGRES_USER:=frdoe_f3der1c0_ppjct}"
: "${POSTGRES_PASSWORD:=tpqXXsvRRRRTYGlapqeVDSASA3ss234dcwedcVGrjwsnjw}"
: "${POSTGRES_PORT:=5432}"
: "${POSTGRES_HOST:=localhost}"
: "${POSTGRES_DB:=frdoe_ddbb}"

# Export PostgreSQL environment variables
export PGUSER="$POSTGRES_USER"
export PGPASSWORD="$POSTGRES_PASSWORD"
export PGHOST="$POSTGRES_HOST"
export PGPORT="$POSTGRES_PORT"

# Function to create users and databases
function create_user_and_databases() {
    local database=$1
    local user=$2
    local password=$3
    echo "Creating user and database '$database'"
    psql -v ON_ERROR_STOP=1 <<-EOSQL
        -- Create the user and database
        CREATE USER $user WITH PASSWORD '$password';
        CREATE DATABASE $database;
        
        -- Grant privileges
        GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
        
        -- Connect to the specific database
        \c $database
        
        -- Create supabase_auth_admin role if it doesn't exist
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'supabase_auth_admin') THEN
                CREATE ROLE supabase_auth_admin;
            END IF;
        END
        \$\$;
        
        -- Grant necessary permissions
        GRANT ALL ON SCHEMA public TO $user;
        GRANT ALL ON SCHEMA public TO supabase_auth_admin;
        ALTER ROLE $user SET search_path TO public;
        
        -- Grant default privileges
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $user;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $user;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO $user;
        
        -- Grant permissions to supabase_auth_admin
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO supabase_auth_admin;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO supabase_auth_admin;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO supabase_auth_admin;
EOSQL
}

# APPFLOWY DATABASE AND USER
APPFLOWY_DB_USER=aapdoewy
APPFLOWY_DB_NAME=aapdoe_dbase
APPFLOWY_DB_PASS=ssWWAFdsdsYYgGGpac33334m

# Create the appflowy database and user
create_user_and_databases "$APPFLOWY_DB_NAME" "$APPFLOWY_DB_USER" "$APPFLOWY_DB_PASS"

# Create necessary extensions for APPFLOWY
psql -v ON_ERROR_STOP=1 -d "$APPFLOWY_DB_NAME" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgvector";
EOSQL

# Additional setup for main database if needed
psql -v ON_ERROR_STOP=1 -d "$POSTGRES_DB" <<-EOSQL
    -- Add any specific setup for the main database here if needed
EOSQL
