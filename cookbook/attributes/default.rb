# RVM settings
default['rvm']['default_ruby'] = ['2.3.3']
default['rvm']['user_default_ruby'] = ['2.3.3']

# Install nginx or not
default['redguide']['install_nginx'] = true

# Install MySQL or not
default['redguide']['install_mysql'] = true

# If current installation for development?
default['redguide']['development'] = false

# Database config
default['redguide']['database'] = {
    'user' => 'root',
    'host' => '127.0.0.1',
    'port' => 3306,
    'password' => 'ilikerandompasswords',
    'database' => 'redguide',
}

# Application name
default['redguide']['name'] = 'redguide'

# Redguide base dir
default['redguide']['base_dir'] = "/opt/#{node['redguide']['name']}/"

# Rails App base dir
default['redguide']['rails_dir'] = ::File.join(node['redguide']['base_dir'], 'web')

# App server
# Possible values +'puma'+ and +'unicorn'+
default['redguide']['appserver']['provider'] = 'unicorn'

# Bind port for Puma app server
default['redguide']['appserver']['unicorn']['bind_port'] = 3000

