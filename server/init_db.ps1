$env:PGPASSWORD='local_pass'
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

& $psqlPath -U postgres -c "DROP DATABASE IF EXISTS vites_db;"
& $psqlPath -U postgres -c "DROP USER IF EXISTS vites_user;"
& $psqlPath -U postgres -c "CREATE USER vites_user WITH ENCRYPTED PASSWORD 'local_pass';"
& $psqlPath -U postgres -c "CREATE DATABASE vites_db owner vites_user;"
& $psqlPath -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE vites_db TO vites_user;"
& $psqlPath -U postgres -c "ALTER USER vites_user WITH SUPERUSER;"
