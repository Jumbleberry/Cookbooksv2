name "base"
maintainer "Ian Elliott"
maintainer_email "ian@jumbleberry.com"
license "All Rights Reserved"
description "Configures the basebox for all Jumbleberry Applications"
version "0.1.0"
chef_version ">= 12.1" if respond_to?(:chef_version)

depends "apt"
depends "configure"
depends "consul"
depends "consul-template"
depends "trusted_certificate"
depends "sysctl"
depends "redisio"
depends "dnsmasq"
depends "hashicorp-vault"
depends "openresty"
depends "openssl-source"
