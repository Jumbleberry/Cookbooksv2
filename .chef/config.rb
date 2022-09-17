current_dir                     = File.dirname(__FILE__)

environment                     "dev"
local_mode                      true
chef_zero.enabled               true
file_cache_path                 "#{current_dir}/local-mode-cache/chef"
file_backup_path                "#{current_dir}/local-mode-cache/backup"
cookbook_path                   ["#{current_dir}/../"]
environment_path                ["#{current_dir}/environments"]
node_path                       ["#{current_dir}/nodes"]
role_path                       ["#{current_dir}/roles"]
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