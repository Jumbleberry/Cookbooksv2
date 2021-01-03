if node["environment"] != "prod"
  # Copy config files
  cookbook_file "/etc/postgresql/12/main/pg_hba.conf" do
    source "pg_hba.conf"
    owner "root"
    group "root"
    mode "0644"
  end
  cookbook_file "/etc/postgresql/12/main/postgresql.conf" do
    source "postgresql.conf"
    owner "root"
    group "root"
    mode "0644"
  end

  # Tune pgsql for timescale
  execute "tune-and-restart-pgsql" do
    command "sudo timescaledb-tune -yes -quiet"
    user "root"
    notifies :reload, "service[postgresql.service]", :immediate
    only_if { node["configure"]["services"]["postgresql"] && (node["configure"]["services"]["postgresql"].include? "start") }
  end

  # Create pgsql user 'root' if it doesn't exist
  execute "pgsql-default-user" do
    command "psql -c \"CREATE USER root WITH PASSWORD '#{node["pgsql"]["root_password"]}' SUPERUSER\""
    user "postgres"
    not_if "psql -U postgres -c \"select * from pg_user\" | grep -c root", :user => "postgres"
  end

  # Create pgsql db 'local_timescale' if it doesn't exist
  execute "pgsql-default-db" do
    command "psql -c \"CREATE DATABASE local_timescale\""
    user "postgres"
    not_if "psql -U postgres -lqt | grep -qw local_timescale", :user => "postgres"
  end

  # conver the pgdb to timescaledb
  execute "convert-pgdb-to-timescaledb" do
    command "psql -c \"CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE\" -d local_timescale"
    user "postgres"
  end
end
