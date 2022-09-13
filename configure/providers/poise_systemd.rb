require "poise_service/service_providers/systemd"

PoiseService::ServiceProviders::Systemd.class_eval do
  private

  def systemctl_daemon_reload
    edit_resource(:execute, "systemctl daemon-reload") do
      command ":" if node[:container]
      action :nothing
      user "root"
    end
  end
end
