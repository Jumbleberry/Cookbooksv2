include_recipe "datadog::dd-agent"

edit_resource(:service, "datadog-agent") do
  action %i{disable stop}
end
