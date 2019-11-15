include_recipe "consul-template"

edit_resource(:template, "/etc/systemd/system/consul-template.service") do
  source "consul-template.service.erb"
  cookbook "base"
  notifies :run, "execute[systemctl-daemon-reload]", :immediately
  notifies :stop, "service[consul-template]", :immediately
end

edit_resource(:service, "consul-template") do
  action %i{stop disable}
end

edit_resource(:user, "www-data") do
  home node["openresty"]["user_home"]
  shell node["openresty"]["user_shell"]
  uid node["openresty"]["user_id"]
  gid node["openresty"]["group_id"]
  action :create
end

# Clear delayed restart notification that will re-enable consul
ruby_block "clearing delayed consul-template notifications" do
  block do
    run_context.delayed_notification_collection.each do |from, notification_array|
      notification_array.each do |notification|
        notification.action = :nothing
      end
    end
  end
end
