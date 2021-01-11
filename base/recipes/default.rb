include_recipe "apt"

unless node.attribute?(:ec2)
  include_recipe cookbook_name + "::trust"
  include_recipe cookbook_name + "::berks"
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
include_recipe cookbook_name + "::timescale"

include_recipe "security"

ruby_block "clearing delayed notifications for disabled services" do
  block do
    services = node[:configure][:services] || {}

    # Check all delayed notifications to ensure a service we care about isn't leaked by ending in an unexpected state
    run_context.delayed_notification_collection.each do |from, notification_array|
      notification_array.each do |notification|
        resource_type = notification.resource.declared_type.to_s
        resource_name = notification.resource.name

        # Treat restart/reload as a subset of start
        action = { "restart" => "start", "reload" => "start" }[notification.action.to_s] || notification.action.to_s

        # See what actions are allowed
        allowed_actions = (node["recipes"].include?("configure::services") ? services[resource_name] : []) || []

        # One of the services we managing is trying to do
        if resource_type.include?("service") && services.keys.include?(resource_name) && !allowed_actions.include?(action)
          Chef::Log.warn("Overriding delayed action #{action} on #{resource_type}[#{resource_name}] to prevent service leak")
          notification.action = :nothing
        end
      end
    end
  end
end
