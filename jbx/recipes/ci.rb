if node["environment"] != "prod"
  execute "seed_dev_jb" do
    command "/usr/bin/php #{node["jbx"]["path"]}/command seed:fresh --load-dump --up --no-interaction"
    user node[:user]
    action :run
  end

  random_id = rand(36 ** 16).to_s(36)
  execute "phpunit" do
    command <<-EOH
      #{node["jbx"]["path"]}/command github:check --shasum #{node["jbx"]["branch"]} & (\
        #{node["jbx"]["path"]}/phpunit --log-junit /tmp/#{random_id}.xml > /tmp/#{random_id}.txt; \
        #{node["jbx"]["path"]}/command github:check --shasum #{node["jbx"]["branch"]} --junit /tmp/#{random_id}.xml --phpunit /tmp/#{random_id}.txt \
      ) &
    EOH
    cwd node["jbx"]["path"]
    action :run
  end
end
