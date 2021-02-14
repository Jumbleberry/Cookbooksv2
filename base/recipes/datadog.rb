include_recipe "datadog::dd-agent"

edit_resource(:service, "datadog-agent") do
  action %i{disable stop}
end

["process", "security", "sysprobe", "trace"].each do |service_name|
  edit_resource(:service, "datadog-agent-" + service_name) do
    action %i{disable stop}
  end
end
