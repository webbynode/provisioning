# --- Install packages we need ---

package 'curl'
package 'git-core'
 
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
  source "delete_app.erb"
  owner 'deploy'
  mode '0744'
end

template "/var/webbynode/templates/rails/database.yml" do
  source "database.yml.erb"
  owner 'deploy'
  mode '0644'
end

