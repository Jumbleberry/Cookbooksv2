cookbook_name = "base"

default[cookbook_name]["packages"] = ["git", "make", "curl", "unzip", "uuid", "mysql-client-5.7", "redis-tools", "libpcre3-dev"]
default[cookbook_name]["trusted_roots"] = ["rootCA.crt", "betwixtCA.crt"]

default[cookbook_name]["kernel"]["shmmax"] = "201326592"
default[cookbook_name]["kernel"]["shmall"] = "268435456"
default[cookbook_name]["kernel"]["shmmni"] = "8192"

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
default["dnsmasq"]["dns_options"] = [
  "no-poll",
  "no-resolv",
  "domain-needed",
  "bogus-priv",
]

default["hashicorp-vault"]["gems"] = {
  "vault" => "0.12.0",
}
default["hashicorp-vault"]["version"] = "1.0.0-beta1"
default["hashicorp-vault"]["config"]["path"] = "/etc/vault/vault.json"
default["hashicorp-vault"]["config"]["address"] = "https://vault.jumbleberry.com"

default["consul_template"]["service_user"] = "www-data"
default["consul_template"]["service_group"] = "www-data"
default["consul_template"]["consul_addr"] = "127.0.0.1:8500"
default["consul_template"]["vault_addr"] = default["hashicorp-vault"]["config"]["address"]

# default['openresty']['source']['version']     = '1.11.2.5'
# default['openresty']['source']['file_prefix'] = 'openresty'
# default['openresty']['source']['checksum']    = 'f8cc203e8c0fcd69676f65506a3417097fc445f57820aa8e92d7888d8ad657b9'

default["openresty"]["user_home"] = "/dev/null"
default["openresty"]["service"]["restart_on_update"] = false
default["openresty"]["service"]["start_on_boot"] = false

default["php"]["version"] = php_version = "7.1"
default["php"]["composer_download_path"] = "/tmp/composer-install.php"
default["php"]["packages"] = {
  "php#{php_version}-fpm" => "*",
  "php#{php_version}-common" => "*",
  "php#{php_version}-mysql" => "*",
  "php#{php_version}-mcrypt" => "*",
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
}

default["gearman"]["version"] = "1.1.*"

default["phalcon"]["install_script"] = "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh"
default["phalcon"]["version"] = "3.4.1-1+php#{php_version}"
default["phalcon"]["devtools"] = "https://github.com/phalcon/phalcon-devtools.git"
