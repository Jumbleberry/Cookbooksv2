cookbook_name = "base"

default[cookbook_name]["trusted_roots"] = ["rootCA.crt", "betwixtCA.crt"]

default[cookbook_name]["kernel"]["shmmax"] = "201326592"
default[cookbook_name]["kernel"]["shmall"] = "268435456"
default[cookbook_name]["kernel"]["shmmni"] = "8192"
default[cookbook_name]["net"]["core.somaxconn"] = "4096"
default[cookbook_name]["net"]["ipv4.tcp_max_syn_backlog"] = "4096"
default[cookbook_name]["net"]["ipv4.tcp_tw_reuse"] = "1"
default[cookbook_name]["net"]["ipv4.tcp_slow_start_after_idle"] = "0"

default["apt"]["compile_time_update"] = true
override["configure"]["update"] = true
override["configure"]["upgrade"] = true

default["datadog"]["histogram_aggregates"] = "max, avg"

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
default["dnsmasq"]["dns_options"] = %w{
  no-poll
  no-resolv
  domain-needed
  bogus-priv
}

default["redisio"]["package_install"] = false
default["redisio"]["bypass_setup"] = false
default["redisio"]["version"] = "5.0.5"

default["hashicorp-vault"]["gems"] = {
  "vault" => "0.13.0",
}
default["hashicorp-vault"]["version"] = "1.2.3"
default["hashicorp-vault"]["config"]["path"] = "/etc/vault/vault.json"
default["hashicorp-vault"]["config"]["address"] = "https://vault.jumbleberry.com"

default["consul"]["config"]["bind_addr"] = node["ipaddress"]
default["consul"]["config"]["advertise_addr"] = node["ipaddress"]
default["consul"]["config"]["advertise_addr_wan"] = node["ipaddress"]

default["consul_template"]["service_user"] = "www-data"
default["consul_template"]["service_group"] = "www-data"
default["consul_template"]["consul_addr"] = "127.0.0.1:8500"
default["consul_template"]["vault_addr"] = default["hashicorp-vault"]["config"]["address"]

default["openssl_source"]["openssl"]["version"] = "1.0.2p"
default["openssl_source"]["openssl"]["prefix"] = "/usr"
default["openssl_source"]["openssl"]["url"] = "https://www.openssl.org/source/openssl-#{default["openssl_source"]["openssl"]["version"]}.tar.gz"
default["openssl_source"]["openssl"]["checksum"] = "50a98e07b1a89eb8f6a99477f262df71c6fa7bef77df4dc83025a2845c827d00"
default["openssl_source"]["openssl"]["configure_flags"] = [
  "--openssldir=/etc/ssl",
  "--libdir=lib",
  "shared",
  "-Wl,-R,'$(LIBRPATH)'",
  "-Wl,--enable-new-dtags",
]

default["openresty"]["source"]["version"] = "1.11.2.5"
default["openresty"]["source"]["file_prefix"] = "openresty"
default["openresty"]["source"]["checksum"] = "f8cc203e8c0fcd69676f65506a3417097fc445f57820aa8e92d7888d8ad657b9"
default["openresty"]["max_subrequests"] = 250
default["openresty"]["extra_modules"] += ["base::openresty_modules"]
default["openresty"]["configure_flags"] = [
  "--add-module=/tmp/nginx_upstream_check_module-master",
]

default["openresty"]["service"]["restart_on_update"] = false
default["openresty"]["service"]["start_on_boot"] = false

default["openresty"]["luarocks"]["version"] = "3.2.0"
default["openresty"]["luarocks"]["url"] = "http://luarocks.org/releases/luarocks-#{node["openresty"]["luarocks"]["version"]}.tar.gz"
default["openresty"]["luarocks"]["checksum"] = "66c1848a25924917ddc1901e865add8f19f2585360c44a001a03a8c234d3e796"

default["openresty"]["luarocks"]["default_rocks"] = {
  "lua-resty-auto-ssl" => "0.13.1",
  "jumbleberry-dogstatsd" => "1.0.1-1",
}

default["php"]["version"] = php_version = "7.3"
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
}

default["gearman"]["version"] = "1.1.*"
default["gearman"]["manager"]["repository"] = "https://github.com/brianlmoon/GearmanManager.git"
default["gearman"]["manager"]["revision"] = "ffc828dac2547aff76cb4962bb3fcc4f454ec8a2"

default["phalcon"]["install_script"] = "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh"
default["phalcon"]["version"] = "3.4.5-1+php#{php_version}"
default["phalcon"]["devtools"] = "https://github.com/phalcon/phalcon-devtools.git"

default["nodejs"]["install_method"] = "binary"
default["nodejs"]["version"] = "12.13.0"
default["nodejs"]["binary"]["checksum"] = "c69671c89d0faa47b64bd5f37079e4480852857a9a9366ee86cdd8bc9670074a"

default["mysql"]["root_password"] = "root"
default["pgsql"]["root_password"] = "root"
