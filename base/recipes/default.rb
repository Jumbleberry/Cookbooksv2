include_recipe "apt"

if node["environment"] != "prod"
  include_recipe cookbook_name + "::trust"
end

unless node.attribute?(:ec2)
  include_recipe cookbook_name + "::berks"
  include_recipe cookbook_name + "::timescale"
end

include_recipe cookbook_name + "::dnsmasq"
include_recipe cookbook_name + "::kernel"
include_recipe cookbook_name + "::filesystem"
include_recipe cookbook_name + "::php"
include_recipe cookbook_name + "::vault"
include_recipe cookbook_name + "::consul"
include_recipe cookbook_name + "::consul-template"
include_recipe cookbook_name + "::redis"
include_recipe cookbook_name + "::openssl"
include_recipe cookbook_name + "::openresty"
include_recipe cookbook_name + "::phalcon"
include_recipe cookbook_name + "::gearman"
include_recipe cookbook_name + "::nodejs"
include_recipe cookbook_name + "::mysql"

include_recipe "security"
