# Install pgsql server
execute "pgsql-install" do
  command <<-EOH
    sudo sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/ubuntu/ `lsb_release -c -s` main' > /etc/apt/sources.list.d/timescaledb.list"
    wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
  EOH
  user "root"
end

# Install timescale
apt_repository "timescale-ppa" do
  uri "ppa:timescale/timescaledb-ppa"
end

apt_update "update-timescale" do
  frequency 86400
  action :periodic
end

package "timescaledb-postgresql-12" do
  action :remove
  notifies :stop, "service[postgresql.service]", :immediately
end

package "timescaledb-loader-postgresql-12" do
  action :remove
  notifies :stop, "service[postgresql.service]", :immediately
end

package "timescaledb-2-postgresql-13" do
  options '-o Dpkg::Options::="--force-overwrite"'
  action :install
end

package "pgloader" do
  action :install
end

# define postgresql service
service "postgresql.service" do
  service_name "postgresql"
  action %i{stop disable}
end
