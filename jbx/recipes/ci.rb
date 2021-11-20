require "shellwords"

if node["environment"] != "prod"
  random_id = node["jbx"]["branch"].gsub(/[^0-9A-Za-z]/, "-") + "_" + rand(36 ** 8).to_s(36)

  cleanup = ""
  # If this is a single-commit ci build, delete the db & dist after running
  if (node["jbx"]["branch"] == node["jbx"]["branch"].gsub(/[^0-9A-Za-z]/, "-") && node["jbx"]["branch"].length == 40 &&
      node["jbx"]["path"].start_with?("/var/www/jbx/dist/"))
    cleanup = "#{node["jbx"]["path"]}/command seed:fresh --drop --no-interaction; rm -rf #{Shellwords.escape(node["jbx"]["path"])};"
  end

  execute "phpunit" do
    command <<-EOH
      #{node["jbx"]["path"]}/command github:check --shasum #{node["jbx"]["branch"]} &
      (\
        #{node["jbx"]["path"]}/phpunit --log-junit /tmp/#{random_id}.xml > /tmp/#{random_id}.txt; \
        #{node["jbx"]["path"]}/command github:check --shasum #{node["jbx"]["branch"]} --junit /tmp/#{random_id}.xml --phpunit /tmp/#{random_id}.txt; \
        DATADOG_API_KEY=#{node["datadog"]["api_key"]} DD_ENV=ci \
            GITHUB_ACTION=codebuild \
            GITHUB_REPOSITORY=$(git config --get remote.origin.url | cut -d ":" -f2 | cut -f 1 -d '.') \
            GITHUB_SHA=$(git rev-parse HEAD) \
            GITHUB_HEAD_REF=$(git branch -a --contains HEAD 2>/dev/null | sed -n 2p | awk '{ printf $1 }' | cut -c16-) \
            datadog-ci junit upload --service jbx unit-tests/junit-reports /tmp/#{random_id}.xml; \
        #{cleanup} \
      ) &
    EOH
    environment ({ "ENV" => node[:environment] })
    cwd node["jbx"]["path"]
    action :run
  end
end
