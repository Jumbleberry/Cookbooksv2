# Install pgsql server
execute "pgsql-install" do
  command "echo \"deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c -s)-pgdg main\" | sudo tee /etc/apt/sources.list.d/pgdg.list; wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -"
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
  action :install
end

# define postgresql service
service "postgresql.service" do
  service_name "postgresql"
  action %i{stop disable}
end
