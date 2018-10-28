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

# default['openresty']['source']['version']     = '1.11.2.5'
# default['openresty']['source']['file_prefix'] = 'openresty'
# default['openresty']['source']['checksum']    = 'f8cc203e8c0fcd69676f65506a3417097fc445f57820aa8e92d7888d8ad657b9'

default["openresty"]["service"]["restart_on_update"] = false
default["openresty"]["service"]["start_on_boot"] = false

default["php"]["version"] = php_version = "php7.1"
default["php"]["composer_download_path"] = "/tmp/composer-install.php"
default["php"]["packages"] = {
  "#{php_version}-fpm" => "*",
  "#{php_version}-common" => "*",
  "#{php_version}-mysql" => "*",
  "#{php_version}-mcrypt" => "*",
  "#{php_version}-zip" => "*",
  "#{php_version}-memcache" => "*",
  "#{php_version}-cli" => "*",
  "#{php_version}-apcu" => "*",
  "#{php_version}-xml" => "*",
  "#{php_version}-dev" => "*",
  "#{php_version}-bcmath" => "*",
  "#{php_version}-redis" => "*",
  "#{php_version}-curl" => "*",
  "#{php_version}-mbstring" => "*",
  "#{php_version}-gettext" => "*",
  "#{php_version}-gd" => "*",
}

default["phalcon"]["install_script"] = "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh"
default["phalcon"]["version"] = "3.4.1-1+#{php_version}"
default["phalcon"]["devtools"] = "https://github.com/phalcon/phalcon-devtools.git"
