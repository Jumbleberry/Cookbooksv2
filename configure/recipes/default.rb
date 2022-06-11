node.default[:commit_hash] = "null"

ruby_block "jbx_version" do
  block do
    %s(su #{node[:user]; git config --global --add safe.directory #{node["jbx"]["path"]})
    commit_hash = %x(cd #{node["jbx"]["path"]}; git rev-parse HEAD)
    node.default[:commit_hash] = "#{commit_hash.strip}"
  end
  action :run
end

include_recipe cookbook_name + "::dnsmasq"
include_recipe cookbook_name + "::network"

include_recipe "base::apt"
include_recipe "ulimit"

include_recipe cookbook_name + "::common"
include_recipe cookbook_name + "::vault"
include_recipe cookbook_name + "::consul"
include_recipe cookbook_name + "::consul-template"
include_recipe cookbook_name + "::openresty"
include_recipe cookbook_name + "::php"
include_recipe cookbook_name + "::gearman"
include_recipe cookbook_name + "::redis"
include_recipe cookbook_name + "::github"
include_recipe cookbook_name + "::nodejs"
include_recipe cookbook_name + "::mysql"
include_recipe cookbook_name + "::ssh"
include_recipe cookbook_name + "::timescale"
include_recipe cookbook_name + "::datadog"

# Manage services at the end
include_recipe cookbook_name + "::services"
include_recipe cookbook_name + "::elb_register"
