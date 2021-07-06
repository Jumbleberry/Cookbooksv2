include_recipe cookbook_name + "::dnsmasq"

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
