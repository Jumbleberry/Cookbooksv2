current_dir                     = File.dirname(__FILE__)
chef_env                        = File.exist?(__dir__ + "/environments") ? current_dir : "/vagrant/cookbooks/.chef"

environment                     "dev"
local_mode                      true
chef_zero.enabled               true
file_cache_path                 "#{current_dir}/local-mode-cache/chef"
file_backup_path                "#{current_dir}/local-mode-cache/backup"
cookbook_path                   case __dir__
    when /vagrant-chef/ then ["/vagrant/cookbooks"]
    when /packer-chef-solo/ then ["#{current_dir}/cookbooks-0"]
    else ["#{current_dir}/../"]
end
environment_path                ["#{chef_env}/environments"]
node_path                       ["#{chef_env}/nodes"]
role_path                       ["#{chef_env}/roles"]
listen                          false
no_lazy_load                    true
rest_timeout                    60
cookbook_sync_threads           16
http_retry_count                3
http_retry_delay                0
automatic_attribute_whitelist   []
default_attribute_whitelist     []
normal_attribute_whitelist      []
override_attribute_whitelist    []