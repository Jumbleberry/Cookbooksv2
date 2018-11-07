cookbook_name = "configure"

default[cookbook_name]["plugin_path"] = "/etc/chef/ohai_plugins"

default["etc_environment"] = {
  "VAULT_ADDR" => "https://vault.jumbleberry.com",
  "ENV" => node["chef_environment"] || node["environment"],
  "GITHUB" => ::File.exist?("/home/vagrant/.github-token") ? IO.read("/home/vagrant/.github-token").strip : "",
}

default["timezone_iii"]["timezone"] = node["tz"]

default["openresty"]["keepalive_requests"] = 1024
default["openresty"]["keepalive_timeout"] = 300
default["openresty"]["open_file_cache"]["max"] = 10000
default["openresty"]["open_file_cache"]["inactive"] = "5m"
default["openresty"]["open_file_cache"]["valid"] = "5m"
default["openresty"]["open_file_cache"]["min_uses"] = 2
default["openresty"]["gzip_comp_level"] = 6

default["php"]["fpm"]["display_errors"] = "Off"
default["php"]["fpm"]["listen"] = "/var/run/php5-fpm.sock"
default["php"]["fpm"]["pm"] = "dynamic"
default["php"]["fpm"]["max_children"] = "100"
default["php"]["fpm"]["start_servers"] = "10"
default["php"]["fpm"]["min_spare_servers"] = "10"
default["php"]["fpm"]["max_spare_servers"] = "40"
default["php"]["fpm"]["include_path"] = ".:/usr/share/php:/var/www/lib"

default["php"]["fpm"]["conf_dirs"] = ["/etc/php/#{node["php"]["version"]}/mods-available"]
default["php"]["fpm"]["conf_dirs_alias"] = ["/etc/php/#{node["php"]["version"]}/cli/conf.d", "/etc/php/#{node["php"]["version"]}/fpm/conf.d"]

default["gearman"]["retries"] = 1
