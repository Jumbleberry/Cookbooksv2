apt_update "update" do
  frequency 86400
  action :periodic
end

include_recipe "configure::base"

if node["environment"] != "production"
  include_recipe cookbook_name + "::trust"
end

include_recipe "dnsmasq"

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

# Instance is on AWS
if node.attribute?(:ec2)
end
