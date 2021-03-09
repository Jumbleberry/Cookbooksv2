if node[:configure][:update]
  execute "apt-get update" do
    action :run
  end
end

if node[:configure][:upgrade]
  execute "DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq" do
    action :run
  end
end

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
end
