name 'configure'
maintainer 'Ian Elliott'
maintainer_email 'ian@jumbleberry.com'
license 'All Rights Reserved'
description 'Configures common settings for every chef run'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'dnsmasq'
depends 'ohai'
depends 'opsworks_stack_state_sync'
depends 'timezone_iii'
depends 'ntp'
depends 'ssh_known_hosts'