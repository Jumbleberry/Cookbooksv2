# Install pgsql server
execute "pgsql-install" do
  command <<-EOH
    sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main' > /etc/apt/sources.list.d/pgdg.list" \
      && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
      && sudo sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/ubuntu/ focal main' > /etc/apt/sources.list.d/timescaledb.list" \
      && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
  EOH
  user "root"
end

# Install timescale
apt_repository "timescale-ppa" do
  uri "ppa:timescale/timescaledb-ppa2"
  distribution "focal"
  retries 5
end

apt_update "update-timescale-2" do
  frequency 86400
  action :periodic
end

package "timescaledb-postgresql-12" do
  action :remove
  notifies :stop, "service[postgresql.service]", :before
end

package "timescaledb-loader-postgresql-12" do
  action :remove
end

package "pgloader" do
  action :remove
end

execute 'DEBIAN_FRONTEND=noninteractive apt-get install -yq timescaledb-2-loader-postgresql-14 timescaledb-2-postgresql-14 -o Dpkg::Options::="--force-overwrite"'

# define postgresql service
service "postgresql.service" do
  service_name "postgresql"
  provider Chef::Provider::Service::Systemd
  action %i{stop disable}
end

if platform?("ubuntu") && node["lsb"]["release"].to_i >= 18
  arch = case node['kernel']['machine']
    when 'aarch64', 'arm64' then 'arm64'
    else 'amd64'
  end

  cookbook_file "/usr/local/bin/pgloader" do
    mode "0755"
    source "pgloader_#{arch}"
  end
else
  include_recipe cookbook_name + "::pgloader"
end

execute "timescale purge" do
  command <<-EOH
    if [ -f $(pg_config --pkglibdir)/timescaledb-tsl-1*.so ]; then rm -f $(ls -1 $(pg_config --pkglibdir)/timescaledb-tsl-1*.so | grep -v "#{node["timescaledb"]["version"]}"); fi \
      && if [ -f $(pg_config --pkglibdir)/timescaledb-1*.so ]; then rm -f $(ls -1 $(pg_config --pkglibdir)/timescaledb-*.so | grep -v "#{node["timescaledb"]["version"]}"); fi \
      && if [ -f $(pg_config --sharedir)/extension/timescaledb--1*.sql ]; then rm -f $(ls -1 $(pg_config --sharedir)/extension/timescaledb--1*.sql | grep -v "#{node["timescaledb"]["version"]}"); fi
  EOH
end
