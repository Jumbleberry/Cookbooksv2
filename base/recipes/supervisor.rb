if node[:container]
  package "supervisor" do
    action :install
    options "--no-install-recommends"
  end

  execute "start supervisor" do
    command "/usr/bin/supervisord -c /etc/supervisor/supervisord.conf"
    not_if "ps aux | grep [s]upervisord"
  end
    
  # Cron
  template "/etc/supervisor/conf.d/cron.conf" do
    source "cron.conf.erb"
  end

  # Dnsmasq
  template "/etc/supervisor/conf.d/dnsmasq.conf" do
    source "dnsmasq.conf.erb"
  end

  # Consul
  template "/etc/supervisor/conf.d/consul.conf" do
    source "consul.conf.erb"
  end

  # Consul Template
  command = "#{node["consul_template"]["install_dir"]}/consul-template"
  options = "-config #{node["consul_template"]["config_dir"]} " \
            "-consul-addr #{node["consul_template"]["consul_addr"]} " \
            "-vault-addr #{node["consul_template"]["vault_addr"]}"

  template "/etc/supervisor/conf.d/consul-template.conf" do
    source "consul-template.conf.erb"
    variables(
      command: command,
      options: options,
    )
  end

  # Redis
  (node["redisio"]["servers"] || [{ "port" => "6379" }]).each do |current_server|
    server_name = current_server["name"] || current_server["port"]

    template "/etc/supervisor/conf.d/redis@#{server_name}.conf" do
      source "redis.conf.erb"
      variables({
        server_name: server_name,
      })
    end
  end

  # PHP
  template "/etc/supervisor/conf.d/php#{node["php"]["version"]}-fpm.conf" do
    source "php-fpm.conf.erb"
  end

  # Gearman
  template "/etc/supervisor/conf.d/gearman-job-server.conf" do
    source "gearman-job-server.conf.erb"
  end
  template "/etc/supervisor/conf.d/gearman-manager.conf" do
    source "gearman-manager.conf.erb"
  end

  # Nginx
  template "/etc/supervisor/conf.d/nginx.conf" do
    source "nginx.conf.erb"
  end

  # MySQL
  template "/etc/supervisor/conf.d/mysql.conf" do
    source "mysql.conf.erb"
  end

  # Timescale
  template "/etc/supervisor/conf.d/postgresql.conf" do
    source "postgresql.conf.erb"
  end

  execute "supervisorctl update" do
    command "/usr/bin/supervisorctl update"
    action :nothing
  end
end
