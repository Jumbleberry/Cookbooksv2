cookbook_name = 'base'

default[cookbook_name]['packages']      = ['git', 'make', 'curl', 'unzip', 'uuid', 'mysql-client-5.7', 'redis-tools']
default[cookbook_name]['trusted_roots'] = ['rootCA.crt', 'betwixtCA.crt']

default[cookbook_name]['kernel']['shmmax'] = '201326592'
default[cookbook_name]['kernel']['shmall'] = '268435456'
default[cookbook_name]['kernel']['shmmni'] = '8192'

default['dnsmasq']['dns'] = {
  'all-servers'     => nil,
  'log-async'       => 50,
  'cache-size'      => 8192,
  'server'          => [
    '1.1.1.1',
    '1.0.0.1',
    '8.8.8.8',
    '8.8.4.4'
  ]
}
default['dnsmasq']['dns_options'] = [
  'no-poll',
  'no-resolv',
  'domain-needed',
  'bogus-priv'
]