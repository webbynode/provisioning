# --- Install packages we need ---

package 'curl'
package 'git-core'
package 'python-software-properties'

# --- Add some PPAs ---

if platform?(%w{debian ubuntu})
  execute "add-apt-repository ppa:nginx/stable"  do
    action :nothing
  end
  
  execute "apt-get update" do
    action :nothing
  end  
end

# --- Installs the database and web server ---

# include_recipe "#{node[:database][:server]}::server"
# include_recipe "#{node[:webserver][:id]}"
include_recipe "nginx::default"

case node[:database][:server]
when 'mysql'
  include_recipe 'mysql::server'

  package 'libmysqlclient-dev'
  gem_package 'mysql' do
    action :install
  end
  
when 'postgresql'
  package 'postgresql' 
  package 'postgresql-client' 
  package 'postgresql-doc' 
  package 'pgadmin3'
  gem_package 'pg'

  # include_recipe 'postgresql::server'
end

# --- Add the deployment user ---

@home = node[:deployer][:home]

log ">>> HOME is: #{@home}"

user 'deploy' do
  comment 'SSH based deployment user'
  home node[:deployer][:home]
  password node[:deployer][:password] # '$1$gdQZBxNP$jgWCYUfBF9fMXVO2jnpoh1'
  shell '/bin/bash'
end

directory @home do
  action :create
  owner 'deploy'
end

group 'deployers' do
  members ['deploy']
end

cookbook_file "#{@home}/.gitconfig" do
  source 'gitconfig'
  owner 'deploy'
  mode '0644'
end

cookbook_file "#{@home}/.gemrc" do
  source 'gemrc'
  owner 'deploy'
  mode '0644'
end

cookbook_file "#{@home}/.profile" do
  source 'profile'
  owner 'deploy'
  mode '0644'
end

cookbook_file "#{@home}/.bashrc" do
  source 'bashrc'
  owner 'deploy'
  mode '0644'
end

directory "#{@home}/.ssh" do
  owner 'deploy'
  mode '0700'
end

template "#{@home}/.ssh/authorized_keys" do
  source 'authorized_keys.erb'
  owner 'deploy'
  mode '0644'
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
end

# --- Create the webbynode deployment structure ---

directory '/var/webbynode'
directory '/var/webbynode/mappings'
directory '/var/webbynode/backups'
directory '/var/webbynode/templates'
directory '/var/webbynode/templates/rails'

template "/var/webbynode/config_app_db" do
  source "config_app_db.#{node[:database][:server]}.erb"
  owner 'deploy'
  mode '0744'
end

template "/var/webbynode/delete_app" do
  source "delete_app.erb"
  owner 'deploy'
  mode '0744'
end

template "/var/webbynode/list_apps" do
  source "list_apps.erb"
  owner 'deploy'
  mode '0744'
end

template "/var/webbynode/templates/rails/database.yml" do
  source "database.yml.erb"
  owner 'deploy'
  mode '0644'
end

# --- Installs PHD ---

git "/var/webbynode/phd" do
  repository "git://github.com/webbynode/phd.git"
  branch "webbynode2"
  action :sync
end

execute "phd_server_setup" do
  cwd "/var/webbynode/phd"
  command "./phd_server_setup"
  user "root"
  creates "/usr/bin/phd"
end


