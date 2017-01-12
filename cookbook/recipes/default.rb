include_recipe 'selinux::disabled' if node['platform_family'] == 'rhel'

name = node['redguide']['name']
database = node['redguide']['database']
rails_dir = node['redguide']['rails_dir']

# Install MySQL Server
mysql_server_installation_package name do
  action :install
  only_if {node['redguide']['install_mysql']}
end

# Install MySQL Server Service
mysql_service_manager name do
  initial_root_password database['password']
  action [:create, :start]
  only_if {node['redguide']['install_mysql']}
end

# MySQL Client
mysql_client name do
  action :create
  only_if {node['redguide']['install_mysql']}
end

# Install Nginx
include_recipe 'nginx' if node['redguide']['install_nginx']

# Install git and nodejs (required by Rails)
package 'git'
package 'nodejs'

# EPEL repo
package 'epel-release' if node['platform_family'] == 'rhel'

# Install RVM and Ruby 2.3.3
include_recipe 'rvm::system'
rvm_gem 'bundler'

# Rails dir
directory rails_dir do
  recursive true
end

# Checkout RedGuide app
git rails_dir do
  repository 'https://github.com/aleksey-hariton/redguide-rails.git'
  revision 'master'
  action :sync
end

# Create app folders
['log', 'pids', 'sockets'].each do |d|
  directory File.join(rails_dir, 'tmp', d) do
    recursive true
  end
end

rvm_shell 'bundle install' do
  cwd rails_dir
  code 'bundle check || bundle install --without development test'
  action :run
end

# .env file with basic configs
template "#{rails_dir}/.env" do
  source 'env.erb'
end

# Database config
template "#{rails_dir}/config/database.yml" do
  source 'database.yml.erb'
  variables database
end

# Secrets file
cookbook_file "#{rails_dir}/config/secrets.yml" do
  source 'secrets.yml'
end

# Create database
rvm_shell 'db:create' do
  cwd rails_dir
  code 'RAILS_ENV="production" rake db:create'
  only_if {node['redguide']['install_mysql']}
end

# Push migrations
rvm_shell 'db:migrate' do
  cwd rails_dir
  code 'RAILS_ENV="production" rake db:migrate'
  only_if {node['redguide']['install_mysql']}
end

# Seed database
rvm_shell 'db:seed' do
  cwd rails_dir
  code 'RAILS_ENV="production" rake db:seed'
  only_if {node['redguide']['install_mysql']}
end

# Precompile assets
rvm_shell 'precompile assets' do
  cwd rails_dir
  code 'RAILS_ENV="production" rake assets:precompile'
  not_if {node['redguide']['development']}
end

vars = {
    app_dir: rails_dir
}

template '/etc/nginx/default.d/redguide.conf' do
  source 'nginx.redguide.conf.erb'
  variables vars
  notifies :restart, 'service[nginx]', :delayed
  only_if {node['redguide']['install_nginx']}
end

template '/etc/nginx/conf.d/upstream_redguide.conf' do
  source 'nginx.upstream_redguide.conf.erb'
  variables vars
  notifies :restart, 'service[nginx]', :delayed
  only_if {node['redguide']['install_nginx']}
end

template '/etc/init.d/unicorn_redguide' do
  source 'init.d.unicorn_redguide.sh.erb'
  mode '0755'
  variables vars
  notifies :restart, 'service[unicorn_redguide]', :delayed
  only_if {node['redguide']['appserver']['provider'] == 'unicorn'}
end

template "#{rails_dir}/config/unicorn.rb" do
  source 'config.unicorn.rb.erb'
  notifies :restart, 'service[unicorn_redguide]', :delayed
  only_if {node['redguide']['appserver']['provider'] == 'unicorn'}
end

service 'unicorn_redguide' do
  action [:enable, :start]
  only_if {node['redguide']['appserver']['provider'] == 'unicorn'}
end

rvm_shell 'bin/rails s' do
  cwd rails_dir
  code 'RAILS_ENV="development" bin/rails server -d'
  only_if {node['redguide']['development']}
end
