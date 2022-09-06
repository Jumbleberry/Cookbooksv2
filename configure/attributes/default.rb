cookbook_name = "configure"

default[cookbook_name]["plugin_path"] = "/etc/chef/ohai_plugins/"
default[cookbook_name]["packages"] = ["git", "make", "curl", "unzip", "uuid", "redis-tools", "libpcre3-dev", "gcc", "awscli", "sbcl", "libsqlite3-dev", "gawk", "freetds-dev", "libzip-dev", "python3", "python3-pip", "tar", "logrotate"]

if (node["lsb"]["release"].to_i >= 20)
  default[cookbook_name]["packages"] += ["libncurses5", "libpython2-stdlib", "libpython2.7-minimal", "libpython2.7-stdlib", "libtinfo5", "python-is-python2", "python2", "python2-minimal", "python2.7", "python2.7-minimal"]
elsif (node["lsb"]["release"].to_i >= 18)
  default[cookbook_name]["packages"] += ["libpython-stdlib", "libpython2.7-minimal", "libpython2.7-stdlib", "python", "python-minimal", "python2.7", "python2.7-minimal"]
end

default["nodejs"]["npm_packages"] = []

default[cookbook_name]["update"] = false
default[cookbook_name]["upgrade"] = false
default[cookbook_name]["elb"] = { "target_groups" => [] }

default["timezone_iii"]["timezone"] = node["tz"]
default["timezone_iii"]["use_symlink"] = true

default["openresty"]["keepalive_requests"] = 1024
default["openresty"]["keepalive_timeout"] = 300
default["openresty"]["open_file_cache"]["max"] = 10000
default["openresty"]["open_file_cache"]["inactive"] = "5m"
default["openresty"]["open_file_cache"]["valid"] = "5m"
default["openresty"]["open_file_cache"]["min_uses"] = 2
default["openresty"]["gzip_comp_level"] = 6
# Set user/group to 1000 if it's not used by a different user already
default["openresty"]["user_id"] = (node["etc"]["passwd"].reduce(nil) { |user, (key, val)| key != node["user"] && val["uid"] == 1000 ? key : user }) ? 33 : 1000
default["openresty"]["group_id"] = (node["etc"]["group"].reduce(nil) { |group, (key, val)| key != node["user"] && val["gid"] == 1000 ? key : group }) ? 33 : 1000
default["openresty"]["user_home"] = "/var/www"
default["openresty"]["user_shell"] = "/bin/bash"

default["openresty"]["try_aio"] = node.attribute?(:ec2)

default["php"]["fpm"]["display_errors"] = "Off"
default["php"]["fpm"]["listen"] = "/var/run/php7-fpm.sock"
default["php"]["fpm"]["pm"] = "dynamic"
default["php"]["fpm"]["max_children"] = "300"
default["php"]["fpm"]["start_servers"] = "60"
default["php"]["fpm"]["min_spare_servers"] = "60"
default["php"]["fpm"]["max_spare_servers"] = "100"
default["php"]["fpm"]["max_requests"] = "0"
default["php"]["fpm"]["include_path"] = ".:/usr/share/php:/var/www/lib:/usr/share/php/zf1/library"
default["php"]["fpm"]["process_control_timeout"] = 5

php_version = node["php"]["version"] || "7.4"
default["php"]["fpm"]["mods_dirs"] = ["/etc/php/#{php_version}/mods-available"]
default["php"]["fpm"]["conf_dirs"] = ["/etc/php/#{php_version}/cli", "/etc/php/#{php_version}/fpm"]

default["php"]["xdebug"] = {
  "mode" => "debug",
  "client_host" => "10.0.2.2",
  "client_port" => 9003,
  "remote_log" => "/var/log/xdebug.log",
  "max_nesting_level" => 1000,
  "idekey" => "PHPSTORM",
  "start_with_request" => "yes",
}

default["gearman"]["retries"] = 1

default["etc_environment"] = {
  "VAULT_ADDR" => node["hashicorp-vault"]["config"]["address"],
  "VAULT_TOKEN" => ENV["VAULT_TOKEN"] || "",
  "ENV" => node["environment"],
  "GITHUB" => ::File.exist?("/vagrant/www/.github-token") ? IO.read("/vagrant/www/.github-token").strip : "",
  "PHP_IDE_CONFIG" => "serverName=#{node["environment"]}",
}

default["datadog"]["hostname"] = (node.attribute?(:opsworks) ? node["opsworks"]["instance"]["hostname"] : node["hostname"]) + "." + node["environment"]
default["datadog"]["agent_major_version"] = 7
default["datadog"]["api_key"] = "<API_KEY>"
default["datadog"]["application_key"] = "<APP_KEY>"

default["datadog"]["agent_enable"] = false
default["datadog"]["agent_start"] = false
default["datadog"]["enable_profiling"] = false
default["datadog"]["enable_process_agent"] = false
default["datadog"]["enable_trace_agent"] = false
default["datadog"]["enable_logs_agent"] = false
default["datadog"]["trace_env"] = node["environment"]

default["datadog"]["tags"] = {}
default["datadog"]["logs"] = {}
