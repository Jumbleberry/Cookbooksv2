name 'timezone_iii'
maintainer 'Corey Hemminger'
maintainer_email 'hemminger@hotmail.com'
license 'Apache-2.0'
description 'Configures the timezone for node'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.1.7'

chef_version '>= 12.1' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/Stromweld/timezone_iii/issues'

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/Stromweld/timezone_iii'

%w(amazon centos debian fedora gentoo ubuntu pld redhat suse windows).each do |os|
  supports os
end