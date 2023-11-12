#!/bin/bash

# Replace these variables with your actual values
DB_HOST="vector.cnnodvlpldz6.us-east-2.rds.amazonaws.com"
DB_PORT="5432"
DB_USER="root"
export PGPASSWORD="rootpassword"
NEW_DATABASE="vectordb"

# Connect to PostgreSQL and create a new database
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $NEW_DATABASE;"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$NEW_DATABASE" -c "CREATE EXTENSION vector;"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$NEW_DATABASE" -c "CREATE TABLE document_vectors (id SERIAL PRIMARY KEY, title VARCHAR(32), text TEXT, embedding vector(3));"

echo "Database and table creation complete."
