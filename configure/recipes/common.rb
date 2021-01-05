include_recipe cookbook_name + "::user"
include_recipe cookbook_name + "::ipaddress"
include_recipe cookbook_name + "::packages"
include_recipe "opsworks_stack_state_sync"
include_recipe "timezone_iii"
include_recipe "timezone_iii::linux_generic"
include_recipe "ntp"

unless node.attribute?(:ec2)
  include_recipe "root_ssh_agent::ppid"
end

if node.attribute?(:ec2)
  # For partitioning and mounting logic in dev to help ensure mysql is healthy/performant
  if node['environment'] == 'dev' ##This should only run in dev on AWS for NVME disk support/use
    directory 'mysql-non-symlink' do
      path '/nvme/mysql'
      recursive true
      action :delete
      not_if { File.symlink?('/nvme/mysql') }
    end

    directory '/nvme' do
      owner 'www-data'
      group 'www-data'
      mode '0755'
      action :create
    end 

    ## Mount the disk here if it is not mounted

    link '/nvme/mysql' do
      to '/var/lib/mysql'
      action :create
      not_if { File.symlink?('/nvme/mysql') }
    end

  end

  # full plan:
  # mount drive to /nvme
  # copy /var/lib/mysql -> /var/lib/mysql.bak
  # symlink /var/lib/mysql to /nvme/mysql
  # cron per 1 minute copy /var/lib/mysql -> /var/lib/mysql.bak
  # on instance boot:
  # mount drive to /nvme
  # if mysql.bak has contents, copy to /var/lib/mysql
end

ssh_known_hosts_entry "github.com"
