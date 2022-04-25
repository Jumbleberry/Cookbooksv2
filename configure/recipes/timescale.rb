if node["environment"] == "dev"
  # Copy config files
  cookbook_file "/etc/postgresql/13/main/pg_hba.conf" do
    source "pg_hba.conf"
    owner "postgres"
    group "postgres"
    mode "0644"
    notifies :reload, "service[postgresql.service]", :immediate
  end
  cookbook_file "/etc/postgresql/13/main/postgresql.conf" do
    source "postgresql.conf"
    owner "postgres"
    group "postgres"
    mode "0644"
    notifies :restart, "service[postgresql.service]", :immediate
    notifies :run, "execute[convert-pgdb-to-timescaledb]", :delayed
  end

  # Disabled as "postgresql.conf" is already tuned based on this, and re-tuning will ensure an unnecessary update of the postgres.conf file
  # Tune pgsql for timescale
  #   execute "tune-and-restart-pgsql" do
  #     command "sudo timescaledb-tune -yes -quiet"
  #     user "root"
  #     notifies :reload, "service[postgresql.service]", :immediate
  #     only_if { node["configure"]["services"]["postgresql"] && (node["configure"]["services"]["postgresql"].include? "start") }
  #   end

  # Create pgsql user 'root' if it doesn't exist
  execute "pgsql-default-user" do
    command "psql -c \"CREATE USER root WITH PASSWORD '#{node["pgsql"]["root_password"]}' SUPERUSER\""
    user "postgres"
    not_if "psql -U postgres -c \"select * from pg_user\" | grep -c root", :user => "postgres"
  end

  # Create pgsql db 'local_timescale' if it doesn't exist
  execute "pgsql-default-db" do
    command "psql -c \"CREATE DATABASE local_timescale ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0\""
    user "postgres"
    not_if "psql -U postgres -lqt | grep -qw local_timescale", :user => "postgres"
  end

  # conver the pgdb to timescaledb
  execute "convert-pgdb-to-timescaledb" do
    command "psql -c \"CREATE EXTENSION IF NOT EXISTS timescaledb VERSION '2.3.1' CASCADE\" -d local_timescale"
    user "postgres"
    action :nothing
  end
end
