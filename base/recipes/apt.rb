if node.attribute?(:ec2)
  timer_action = node["recipes"].include?("configure::default") ? [:unmask, :start] : [:stop, :mask]

  systemd_unit "apt-daily.service" do
    action [:stop, :disable]
  end
  systemd_unit "apt-daily.timer" do
    action timer_action
  end

  systemd_unit "apt-daily-upgrade.service" do
    action [:stop, :disable]
  end
  systemd_unit "apt-daily-upgrade.timer" do
    action timer_action
  end
else
  # Disable unattended-upgrades inside vagrant
  include_recipe "apt::unattended-upgrades"
  execute "DEBIAN_FRONTEND=noninteractive dpkg-reconfigure unattended-upgrades"
  execute "apt-mark hold unattended-upgrades"
end

if node[:configure][:update]
  apt_update "update package list" do
    frequency 86400
    action :periodic
  end
end

if node["recipes"].include?("configure::base")
  if node[:configure][:upgrade]
    execute "DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq" do
      action :run
    end
  end
end
