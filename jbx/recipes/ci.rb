require "shellwords"

if node["environment"] != "prod"
  branch = node["jbx"]["branch"].gsub(/[^0-9A-Za-z]/, "-")
  random_id = branch + "_" + rand(36 ** 8).to_s(36)
  order_by = node.read("jbx", "phpunit", "order_by") || "default"
  order_by = order_by + (order_by == "defects" ? " --stop-on-failure" : "")

  # kills any zombie phpunit executions
  execute "phpunit cleanup" do
    command "kill -9 $(ps -u root -o comm,pid,etimes | awk '/^phpunit/ {if ($3 > 900) { print $2}}')"
    ignore_failure true
  end

  execute "phpunit" do
    command <<-EOH
      #{node["jbx"]["path"]}/command github:check --shasum #{branch} &
      (\
        #{node["jbx"]["path"]}/phpunit --log-junit /tmp/#{random_id}.xml --cache-result --cache-result-file /tmp/#{branch}.cache --order-by #{order_by} > /tmp/#{random_id}.txt; \
        #{node["jbx"]["path"]}/command github:check --shasum #{branch} --junit /tmp/#{random_id}.xml --phpunit /tmp/#{random_id}.txt; \
      ) &
    EOH
    environment ({ "ENV" => node[:environment] })
    cwd node["jbx"]["path"]
    action :run
  end
end
