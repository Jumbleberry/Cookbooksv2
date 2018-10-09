include_recipe "configure"

# Instance is on AWS
if node.attribute?(:ec2)

end

if node['environment'] != "production"
    include_recipe cookbook_name + "::trust"
end

include_recipe 'dnsmasq'

include_recipe cookbook_name + "::packages"
include_recipe cookbook_name + "::kernel"
include_recipe cookbook_name + "::filesystem"
include_recipe cookbook_name + "::redis"
include_recipe cookbook_name + "::consul"

include_recipe 'hashicorp-vault::default'