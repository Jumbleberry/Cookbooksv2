include_recipe cookbook_name + "::services"
include_recipe cookbook_name + "::common"
include_recipe cookbook_name + "::vault"
include_recipe cookbook_name + "::consul-template"
include_recipe cookbook_name + "::openresty"
include_recipe cookbook_name + "::php"
include_recipe cookbook_name + "::gearman"
include_recipe cookbook_name + "::redis"
include_recipe cookbook_name + "::github"
include_recipe cookbook_name + "::nodejs"
