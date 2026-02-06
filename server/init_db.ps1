$env:PGPASSWORD='local_pass'
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

& $psqlPath -U postgres -c "DROP DATABASE IF EXISTS vivaah_db;"
& $psqlPath -U postgres -c "DROP USER IF EXISTS vivaah_user;"
& $psqlPath -U postgres -c "CREATE USER vivaah_user WITH ENCRYPTED PASSWORD 'local_pass';"
& $psqlPath -U postgres -c "CREATE DATABASE vivaah_db owner vivaah_user;"
& $psqlPath -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE vivaah_db TO vivaah_user;"
& $psqlPath -U postgres -c "ALTER USER vivaah_user WITH SUPERUSER;"
