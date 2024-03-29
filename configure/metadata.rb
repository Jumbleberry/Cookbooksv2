name "configure"
maintainer "Ian Elliott"
maintainer_email "ian@jumbleberry.com"
license "All Rights Reserved"
description "Configures common settings for every chef run"
version "0.1.0"
chef_version ">= 12.1" if respond_to?(:chef_version)

depends "apt"
depends "base"
depends "consul-template"
depends "dnsmasq"
depends "etc_environment"
depends "ohai"
depends "timezone_iii"
depends "ntp"
depends "ssh_known_hosts"
depends "hashicorp-vault"
depends "consul"
depends "redisio"
depends "root_ssh_agent"
depends "nodejs"
depends "line"
depends "datadog"
