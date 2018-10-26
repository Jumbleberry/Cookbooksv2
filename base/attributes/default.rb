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

# default['openresty']['source']['version']     = '1.11.2.5'
# default['openresty']['source']['file_prefix'] = 'openresty'
# default['openresty']['source']['checksum']    = 'f8cc203e8c0fcd69676f65506a3417097fc445f57820aa8e92d7888d8ad657b9'

default["openresty"]["service"]["restart_on_update"] = false
default["openresty"]["service"]["start_on_boot"] = false

default["phalcon"]["install_script"] = "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh"
default["phalcon"]["version"] = "3.4.1-1+php7.1"
default["phalcon"]["devtools"] = "https://github.com/phalcon/phalcon-devtools.git"
