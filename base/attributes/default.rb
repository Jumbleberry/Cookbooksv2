cookbook_name = 'base'

default[cookbook_name]['packages']      = ['git', 'gcc', 'vim', 'libpcre3-dev', 'make', 'curl', 'unzip', 'uuid']
default[cookbook_name]['trusted_roots'] = ['rootCA.crt', 'betwixtCA.crt']

default[cookbook_name]['kernel']['shmmax'] = '201326592'
default[cookbook_name]['kernel']['shmall'] = '268435456'
default[cookbook_name]['kernel']['shmmni'] = '8192'

default[:dnsmasq][:dns] = {
  'no-poll'         => nil,
  'no-resolv'       => nil,
  'no-negcache'     => nil,
  'all-servers'     => nil,
  'min-cache-ttl'   => '30',
  'local-ttl'       => '30',
  'log-async'       => 50,
  'cache-size'      => 8192
}