# --- Install packages we need ---
package 'curl'
package 'git-core'
 
# --- Add the deployment user ---

directory '/var/apps'

user 'deploy' do
  comment 'SSH based deployment user'
  home '/var/apps'
  password '$1$JJsvHslV$szsCjVEroftprNn4JHtDi.'
end

group 'deployers' do
  members ['deploy']
end

file '/var/apps/.gitconfig' do
  content "[receive]\n	denyCurrentBranch = ignore"
end

# --- Create the webbynode deployment structure ---

directory '/var/webbynode/mappings'
directory '/var/webbynode/backups'
directory '/var/webbynode/templates'
directory '/var/webbynode/templates/rails'

file '/var/apps/.gemrc' do
  content "gem: --no-ri --no-rdoc"
end
