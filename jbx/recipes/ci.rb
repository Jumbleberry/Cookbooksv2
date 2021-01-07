if node["environment"] != "prod"
  random_id = rand(36 ** 16).to_s(36)
  execute "phpunit" do
    command <<-EOH
      #{node["jbx"]["path"]}/command github:check && \
      #{node["jbx"]["path"]}/phpunit --log-junit /tmp/#{random_id}.xml > /tmp/#{random_id}.txt && \
      #{node["jbx"]["path"]}/command github:check --junit /tmp/#{random_id}.xml --phpunit /tmp/#{random_id}.txt
    EOH
    cwd node["jbx"]["path"]
    action :run
  end
end
