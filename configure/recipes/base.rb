include_recipe cookbook_name + "::container"
include_recipe "apt"
edit_resource(:execute, "apt-get update") do
  action :run
end

include_recipe cookbook_name + "::common"
include_recipe "base"
