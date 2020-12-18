cookbook_name = "configure"

default[cookbook_name]["plugin_path"] = "/etc/chef/ohai_plugins"
default[cookbook_name]["packages"] = ["git", "make", "curl", "unzip", "uuid", "redis-tools", "libpcre3-dev", "tzdata", "default-jre"]

default["timezone_iii"]["timezone"] = node["tz"]

default["openresty"]["keepalive_requests"] = 1024
default["openresty"]["keepalive_timeout"] = 300
default["openresty"]["open_file_cache"]["max"] = 10000
default["openresty"]["open_file_cache"]["inactive"] = "5m"
default["openresty"]["open_file_cache"]["valid"] = "5m"
default["openresty"]["open_file_cache"]["min_uses"] = 2
default["openresty"]["gzip_comp_level"] = 6
default["openresty"]["user_id"] = 33
default["openresty"]["group_id"] = 33
default["openresty"]["user_home"] = "/var/www"
default["openresty"]["user_shell"] = "/bin/bash"

default["php"]["fpm"]["display_errors"] = "Off"
default["php"]["fpm"]["listen"] = "/var/run/php7-fpm.sock"
default["php"]["fpm"]["pm"] = "dynamic"
default["php"]["fpm"]["max_children"] = "300"
default["php"]["fpm"]["start_servers"] = "60"
default["php"]["fpm"]["min_spare_servers"] = "60"
default["php"]["fpm"]["max_spare_servers"] = "100"
default["php"]["fpm"]["include_path"] = ".:/usr/share/php:/var/www/lib"

php_version = node["php"]["version"] || "7.3"
default["php"]["fpm"]["mods_dirs"] = ["/etc/php/#{php_version}/mods-available"]
default["php"]["fpm"]["conf_dirs"] = ["/etc/php/#{php_version}/cli", "/etc/php/#{php_version}/fpm"]

default["php"]["xdebug"] = {
  "remote_enable" => true,
  "remote_autostart" => true,
  "remote_host" => "10.0.2.2",
  "remote_port" => 9000,
  "remote_log" => "/var/log/xdebug.log",
  "max_nesting_level" => 1000,
}

default["gearman"]["retries"] = 1

default["etc_environment"] = {
  "VAULT_ADDR" => node["hashicorp-vault"]["config"]["address"],
  "VAULT_TOKEN" => ENV["VAULT_TOKEN"] || "",
  "ENV" => node["environment"],
  "GITHUB" => ::File.exist?("/vagrant/www/.github-token") ? IO.read("/vagrant/www/.github-token").strip : "",
  "PHP_IDE_CONFIG" => "serverName=#{node["environment"]}",
}
