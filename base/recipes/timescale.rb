# Install pgsql server
execute "pgsql-install" do
  command "echo \"deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c -s)-pgdg main\" | sudo tee /etc/apt/sources.list.d/pgdg.list; wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -; sudo apt-get update"
  user "root"
end

# Install timescale
apt_repository "timescale-ppa" do
  uri "ppa:timescale/timescaledb-ppa"
end

execute "timescale-install" do
  command "sudo apt-get update; sudo -E apt-get install -y -q timescaledb-postgresql-12"
  user "root"
end

