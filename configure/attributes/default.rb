cookbook_name = "configure"

default[cookbook_name]["plugin_path"] = "/etc/chef/ohai_plugins"

default["etc_environment"] = {
  "VAULT_ADDR" => "https://vault.jumbleberry.com",
  "ENV" => node["chef_environment"] || node["environment"],
  "GITHUB" => ::File.exist?("/home/vagrant/.github") ? IO.read("/home/vagrant/.github").strip : "",
}

default["timezone_iii"]["timezone"] = node["tz"]

default["php"]["fpm"]["display_errors"] = "Off"
default["php"]["fpm"]["listen"] = "/var/run/php5-fpm.sock"
default["php"]["fpm"]["pm"] = "dynamic"
default["php"]["fpm"]["max_children"] = "100"
default["php"]["fpm"]["start_servers"] = "10"
default["php"]["fpm"]["min_spare_servers"] = "10"
default["php"]["fpm"]["max_spare_servers"] = "40"
default["php"]["fpm"]["include_path"] = ".:/usr/share/php:/var/www/lib"

default["php"]["fpm"]["conf_dirs"] = ["/etc/php/7.1/mods-available"]
default["php"]["fpm"]["conf_dirs_alias"] = ["/etc/php/7.1/cli/conf.d", "/etc/php/7.1/fpm/conf.d"]
