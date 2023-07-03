cookbook_name = "base"

default[cookbook_name]["trusted_roots"] = ["rootCA.crt", "betwixtCA.crt", "proxyman.crt"]

default[cookbook_name]["kernel"]["shmmax"] = "201326592"
default[cookbook_name]["kernel"]["shmall"] = "268435456"
default[cookbook_name]["kernel"]["shmmni"] = "8192"
default[cookbook_name]["vm"]["swappiness"] = "10"
unless node.attribute?(:container)
  default[cookbook_name]["net"]["core.somaxconn"] = "4096"
  default[cookbook_name]["net"]["core.rmem_max"] = "134217728"
  default[cookbook_name]["net"]["core.wmem_max"] = "134217728"
  default[cookbook_name]["net"]["core.default_qdisc"] = "fq"
  default[cookbook_name]["net"]["ipv4.tcp_wmem"] = "4096 87380 67108864"
  default[cookbook_name]["net"]["ipv4.tcp_rmem"] = "4096 65536 67108864"
  default[cookbook_name]["net"]["ipv4.tcp_max_syn_backlog"] = "8096"
  default[cookbook_name]["net"]["ipv4.tcp_tw_reuse"] = "1"
  default[cookbook_name]["net"]["ipv4.tcp_slow_start_after_idle"] = "0"
  default[cookbook_name]["net"]["ipv4.tcp_fin_timeout"] = "15"
  default[cookbook_name]["net"]["ipv4.tcp_mtu_probing"] = "0"
  default[cookbook_name]["net"]["ipv4.tcp_congestion_control"] = "bbr"
end

default[cookbook_name]["initcwnd"] = "20"
default[cookbook_name]["initrwnd"] = "20"

override["poise-service"]["provider"] = "systemd"

default["apt"]["compile_time_update"] = true
override["configure"]["update"] = true
override["configure"]["upgrade"] = true

default["datadog"]["histogram_aggregates"] = "max, avg"
default["datadog"]["tracer"]["version"] = "0.84.0"

default["dnsmasq"]["dns"] = {
  "all-servers" => nil,
  "log-async" => 50,
  "cache-size" => 8192,
  "server" => [
    "1.1.1.1",
    "1.0.0.1",
    "8.8.8.8",
    "8.8.4.4",
  ],
}
unless node[:container]
  default["dnsmasq"]["dns"]["user"] = "root"
end
default["dnsmasq"]["dns_options"] = %w{
  no-poll
  no-resolv
  domain-needed
  bogus-priv
  no-negcache
}

install_redis = node["recipes"].include?("configure::base") || node["recipes"].include?("base::redis")
default["redisio"]["package_install"] = !install_redis
default["redisio"]["bypass_setup"] = !install_redis
default["redisio"]["version"] = "6.0.5"
default["redisio"]["job_control"] = "systemd"

default["hashicorp-vault"]["gems"] = {
  "vault" => "0.16.0",
}
default["hashicorp-vault"]["version"] = "1.10.0"
default["hashicorp-vault"]["config"]["path"] = "/etc/vault/vault.json"
default["hashicorp-vault"]["config"]["address"] = "https://vault.squaredance.io"

default["consul"]["config"]["bind_addr"] = node["ipaddress"]
default["consul"]["config"]["advertise_addr"] = node["ipaddress"]
default["consul"]["config"]["advertise_addr_wan"] = node["ipaddress"]

default["consul_template"]["service_user"] = "www-data"
default["consul_template"]["service_group"] = "www-data"
default["consul_template"]["consul_addr"] = "127.0.0.1:8500"
default["consul_template"]["vault_addr"] = node["hashicorp-vault"]["config"]["address"]
override["consul_template"]["init_style"] = "systemd"

default["openssl_source"]["openssl"]["version"] = "1.1.1n"
default["openssl_source"]["openssl"]["abi_version"] = "1.1.1"
default["openssl_source"]["openssl"]["prefix"] = "/opt/openssl-#{node["openssl_source"]["openssl"]["abi_version"]}"
default["openssl_source"]["openssl"]["url"] = "https://www.openssl.org/source/openssl-#{node["openssl_source"]["openssl"]["version"]}.tar.gz"
default["openssl_source"]["openssl"]["checksum"] = "40dceb51a4f6a5275bde0e6bf20ef4b91bfc32ed57c0552e2e8e15463372b17a"
default["openssl_source"]["openssl"]["configure_flags"] = [
  "--openssldir=/etc/ssl",
  "--libdir=lib",
  "shared",
  "-Wl,-R,'$(LIBRPATH)'",
  "-Wl,--enable-new-dtags",
]

default["openresty"]["source"]["version"] = "1.19.3.2"
default["openresty"]["source"]["file_prefix"] = "openresty"
default["openresty"]["source"]["checksum"] = "ce40e764990fbbeb782e496eb63e214bf19b6f301a453d13f70c4f363d1e5bb9"
default["openresty"]["max_subrequests"] = 250
default["openresty"]["extra_modules"] += ["base::openresty_modules"]
default["openresty"]["configure_flags"] = [
  "--add-module=/tmp/nginx_upstream_check_module-master",
  "--with-stream_realip_module",
  "--with-cc-opt=\"-I#{node["openssl_source"]["openssl"]["prefix"]}/include\"",
  "--with-ld-opt=\"-L#{node["openssl_source"]["openssl"]["prefix"]}/lib\"",
] + (node["lsb"]["release"].to_i >= 20 ? ["--with-cc-opt=\"-Wimplicit-fallthrough=0\""] : [])

default["openresty"]["service"]["restart_on_update"] = false
default["openresty"]["service"]["start_on_boot"] = false

default["openresty"]["luarocks"]["version"] = "3.8.0"
default["openresty"]["luarocks"]["url"] = "http://luarocks.org/releases/luarocks-#{node["openresty"]["luarocks"]["version"]}.tar.gz"
default["openresty"]["luarocks"]["checksum"] = "56ab9b90f5acbc42eb7a94cf482e6c058a63e8a1effdf572b8b2a6323a06d923"

default["openresty"]["luarocks"]["default_rocks"] = {
  "jumbleberry-auto-ssl" => "0.13.1-2",
  "jumbleberry-dogstatsd" => "1.0.1-1",
}

default["php"]["version"] = php_version = "8.2"
default["php"]["composer_download_path"] = "/tmp/composer-install.php"
default["php"]["packages"] = {
  "php#{php_version}-fpm" => "*",
  "php#{php_version}-common" => "*",
  "php#{php_version}-mysql" => "*",
  "php#{php_version}-zip" => "*",
  "php#{php_version}-memcache" => "*",
  "php#{php_version}-cli" => "*",
  "php#{php_version}-apcu" => "*",
  "php#{php_version}-xml" => "*",
  "php#{php_version}-dev" => "*",
  "php#{php_version}-bcmath" => "*",
  "php#{php_version}-redis" => "*",
  "php#{php_version}-curl" => "*",
  "php#{php_version}-mbstring" => "*",
  "php#{php_version}-gettext" => "*",
  "php#{php_version}-gd" => "*",
  "php#{php_version}-soap" => "*",
  "php#{php_version}-gearman" => "*",
  "php#{php_version}-xdebug" => "*",
  "php#{php_version}-pgsql" => "*",
  "php#{php_version}-intl" => "*",
  "php#{php_version}-igbinary" => "*",
}

default["gearman"]["version"] = "1.1.*"
default["gearman"]["manager"]["repository"] = "https://github.com/Jumbleberry/GearmanManager.git"
default["gearman"]["manager"]["revision"] = "1.1"

default["phalcon"]["install_script"] = "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh"
default["phalcon"]["version"] = case node["lsb"]["release"].to_i
  when 16, 18 then "3.4.5-1+php7.3"
  else "3.4.5-5+ubuntu#{node["lsb"]["release"]}.1+deb.sury.org+1"
  end

default["phalcon"]["devtools"] = "https://github.com/phalcon/phalcon-devtools.git"

default["nodejs"]["install_method"] = "binary"
default["nodejs"]["version"] = "14.17.4"
default["nodejs"]["binary"]["checksum"] = "c69671c89d0faa47b64bd5f37079e4480852857a9a9366ee86cdd8bc9670074a"
