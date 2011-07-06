# --- Install packages we need ---
package 'curl'
package 'git-core'

# --- Install the gems we need ---

gem_package 'ruby-shadow'
 
# --- Add the deployment user ---

directory '/var/apps'

user 'deploy' do
  comment 'SSH based deployment user'
  home '/var/apps'
  password '$1$gdQZBxNP$jgWCYUfBF9fMXVO2jnpoh1'
  shell '/bin/bash'
end

group 'deployers' do
  members ['deploy']
end

cookbook_file '/var/apps/.gitconfig' do
  source 'gitconfig'
  owner 'deploy'
  mode '0644'
end

cookbook_file '/var/apps/.gemrc' do
  source 'gemrc'
  owner 'deploy'
  mode '0644'
end

cookbook_file '/var/apps/.profile' do
  source 'profile'
  owner 'deploy'
  mode '0644'
end

cookbook_file '/var/apps/.bashrc' do
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

file '/var/apps/.gemrc' do
  content "gem: --no-ri --no-rdoc"
end
