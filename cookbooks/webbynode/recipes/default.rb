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

include_recipe "#{node[:database][:server]}::server"
include_recipe "#{node[:webserver][:id]}"

case node[:database][:server]
when 'mysql'
  package 'libmysqlclient-dev'
  package 'mysql-server'
  gem_package 'mysql'
when 'postgresql'
  package 'postgresql' 
  package 'postgresql-client' 
  package 'postgresql-doc' 
  package 'pgadmin3'
  gem_package 'pg'
end

# --- Add the deployment user ---

@home = node[:deployer][:home]

directory @home

user 'deploy' do
  comment 'SSH based deployment user'
  home @home
  password node[:deployer][:password] # '$1$gdQZBxNP$jgWCYUfBF9fMXVO2jnpoh1'
  shell '/bin/bash'
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
  mode '0700'
end

template "#{@home}/.ssh/authorized_keys" do
  source 'authorized_keys'
  owner 'deployer'
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

