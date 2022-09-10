require "chef/resource/service"
require "chef/provider/service/simple"
require "chef/mixin/which"

class Chef::Provider::Service::Systemd < Chef::Provider::Service::Simple
  include Chef::Mixin::Which

  provides :service, os: "linux" do |node|
    node[:container] || Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
  end

  attr_accessor :status_check_success

  def self.supports?(resource, action)
    Chef::Platform::ServiceHelpers.config_for_service(resource.service_name).include?(:systemd)
  end

  def docker?
    ::File.exist?("/.dockerenv") || !!(::File.read("/proc/1/cgroup") =~ %r[^\d+:\w+:/(lxc|docker)/]) || node["etc"]["passwd"].key?("gitpod")
  end

  def load_current_resource
    @current_resource = Chef::Resource::Service.new(new_resource.name)
    current_resource.service_name(new_resource.service_name)
    @status_check_success = true

    if new_resource.status_command
      Chef::Log.debug("#{new_resource} you have specified a status command, running..")

      unless shell_out(new_resource.status_command).error?
        current_resource.running(true)
      else
        @status_check_success = false
        current_resource.running(false)
        current_resource.enabled(false)
        current_resource.masked(false)
      end
    else
      current_resource.running(is_active?)
    end

    current_resource.enabled(is_enabled?)
    current_resource.masked(is_masked?)
    current_resource
  end

  # systemd supports user services just fine
  def user_services_requirements
  end

  def define_resource_requirements
    shared_resource_requirements
    requirements.assert(:all_actions) do |a|
      a.assertion { status_check_success }
      # We won't stop in any case, but in whyrun warn and tell what we're doing.
      a.whyrun ["Failed to determine status of #{new_resource}, using command #{new_resource.status_command}.",
                "Assuming service would have been installed and is disabled"]
    end
  end

  def get_systemctl_options_args
    if new_resource.user
      uid = node["etc"]["passwd"][new_resource.user]["uid"]
      options = {
        :environment => {
          "DBUS_SESSION_BUS_ADDRESS" => "unix:path=/run/user/#{uid}/bus",
        },
        :user => new_resource.user,
      }
      args = "--user"
    else
      options = {}
      args = "--system"
    end

    [options, args]
  end

  def start_service
    if current_resource.running
      Chef::Log.debug("#{new_resource} already running, not starting")
    else
      if docker?
        shell_out("#{supervisorctl_path} start #{new_resource.service_name}")
      elsif new_resource.start_command
        super
      else
        options, args = get_systemctl_options_args
        shell_out_with_systems_locale!("#{systemctl_path} #{args} start #{new_resource.service_name}", options)
      end
    end
  end

  def stop_service
    unless current_resource.running
      Chef::Log.debug("#{new_resource} not running, not stopping")
    else
      if docker?
        shell_out("#{supervisorctl_path} stop #{new_resource.service_name}")
      elsif new_resource.stop_command
        super
      else
        options, args = get_systemctl_options_args
        shell_out_with_systems_locale!("#{systemctl_path} #{args} stop #{new_resource.service_name}", options)
      end
    end
  end

  def restart_service
    if docker?
      shell_out("#{supervisorctl_path} restart #{new_resource.service_name}")
    elsif new_resource.restart_command
      super
    else
      options, args = get_systemctl_options_args
      shell_out_with_systems_locale!("#{systemctl_path} #{args} restart #{new_resource.service_name}", options)
    end
  end

  def reload_service
    if docker?
      shell_out("#{supervisorctl_path} restart #{new_resource.service_name}")
    elsif new_resource.reload_command
      super
    else
      if current_resource.running
        options, args = get_systemctl_options_args
        shell_out_with_systems_locale!("#{systemctl_path} #{args} reload #{new_resource.service_name}", options)
      else
        start_service
      end
    end
  end

  def enable_service
    if docker?
      shell_out("sed -i '/autostart=false/c\\autostart=true' /etc/supervisor/conf.d/#{new_resource.service_name}.conf")
      shell_out("#{supervisorctl_path} add #{new_resource.service_name}")
    else
      options, args = get_systemctl_options_args
      shell_out!("#{systemctl_path} #{args} enable #{new_resource.service_name}", options)
    end
  end

  def disable_service
    if docker?
      path = "/etc/supervisor/conf.d/#{new_resource.service_name}.conf"
      shell_out("[ -f #{path} ] && sed -i '/autostart=true/c\\autostart=false' #{path}")
      shell_out("#{supervisorctl_path} remove #{new_resource.service_name}")
    else
      options, args = get_systemctl_options_args
      shell_out!("#{systemctl_path} #{args} disable #{new_resource.service_name}", options)
    end
  end

  def mask_service
    if docker?
      true
    else
      options, args = get_systemctl_options_args
      shell_out!("#{systemctl_path} #{args} mask #{new_resource.service_name}", options)
    end
  end

  def unmask_service
    if docker?
      true
    else
      options, args = get_systemctl_options_args
      shell_out!("#{systemctl_path} #{args} unmask #{new_resource.service_name}", options)
    end
  end

  def is_active?
    if docker?
      shell_out("#{supervisorctl_path} status #{new_resource.service_name}").stdout.include?("RUNNING")
    else
      options, args = get_systemctl_options_args
      shell_out("#{systemctl_path} #{args} is-active #{new_resource.service_name} --quiet", options).exitstatus == 0
    end
  end

  def is_enabled?
    if docker?
      shell_out("grep 'autostart=true' /etc/supervisor/conf.d/#{new_resource.service_name}.conf").exitstatus == 0
    else
      options, args = get_systemctl_options_args
      shell_out("#{systemctl_path} is-enabled #{new_resource.service_name} --quiet", options).exitstatus == 0
    end
  end

  def is_masked?
    if docker?
      false
    else
      options, args = get_systemctl_options_args
      s = shell_out("#{systemctl_path} is-enabled #{new_resource.service_name}", options)
      s.exitstatus != 0 && s.stdout.include?("masked")
    end
  end

  private

  def systemctl_path
    if @systemctl_path.nil?
      @systemctl_path = which("systemctl")
    end
    @systemctl_path
  end

  def supervisorctl_path
    if @supervisorctl_path.nil?
      @supervisorctl_path = which("supervisorctl")
    end
    @supervisorctl_path
  end
end
