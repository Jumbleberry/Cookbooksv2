name 'poise-service'
maintainer 'Noah Kantrowitz'
maintainer_email 'noah@coderanger.net'
license 'Apache-2.0'
description 'A Chef cookbook for managing system services.'

version '1.5.2'

%w(ubuntu debian centos redhat amazon scientific fedora oracle suse opensuse opensuseleap freebsd windows zlinux).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/poise-service'
issues_url 'https://github.com/chef-cookbooks/poise-service/issues'
chef_version '>= 12.14'