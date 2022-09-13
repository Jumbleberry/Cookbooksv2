if node["datadog"] && node["datadog"]["application_key"] && node["datadog"]["application_key"] != "<APP_KEY>"
  include_recipe "datadog::dd-handler"
end

include_recipe cookbook_name + "::opsworks"
include_recipe cookbook_name + "::user"
include_recipe cookbook_name + "::ipaddress"
include_recipe cookbook_name + "::nvme"
include_recipe cookbook_name + "::packages"
include_recipe "timezone_iii"
include_recipe "timezone_iii::linux_generic"
unless node.attribute?(:container)
  include_recipe cookbook_name + "::clocksource"
  include_recipe "ntp"
end

unless node.attribute?(:ec2)
  include_recipe "root_ssh_agent::ppid"
end

ssh_known_hosts_entry "github.com"
