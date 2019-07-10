include_recipe "security"
include_recipe "apt"
include_recipe "dnsmasq"

if node["environment"] != "prod"
  include_recipe cookbook_name + "::trust"
end

include_recipe cookbook_name + "::packages"
include_recipe cookbook_name + "::kernel"
include_recipe cookbook_name + "::filesystem"
include_recipe cookbook_name + "::redis"
include_recipe cookbook_name + "::consul"
include_recipe cookbook_name + "::vault"
include_recipe cookbook_name + "::consul-template"
include_recipe cookbook_name + "::openssl"
include_recipe cookbook_name + "::openresty"
include_recipe cookbook_name + "::php"
include_recipe cookbook_name + "::phalcon"
include_recipe cookbook_name + "::gearman"
