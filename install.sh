#!/bin/bash
 
# This runs on the server
 
ruby_binary=/usr/bin/ruby1.9.2
chef_binary=/usr/bin/chef-solo
solo_rb=/root/solo.rb
solo_json=/root/solo.json
provisioning_folder=/root/provisioning

# if ! test -f "$solo_rb"; then
#   echo "root = File.absolute_path(File.dirname(__FILE__))
# 
# file_cache_path root
# cookbook_path root + '/cookbooks'" > $solo_rb
# fi
# 
# if ! test -f "$solo_json"; then
#   echo "{
#     \"run_list\": [ \"recipe[webbynode::default]\" ]
# }" > $solo_json
# fi
 
# Are we on a vanilla system?
if ! test -f "$ruby_binary"; then
    export DEBIAN_FRONTEND=noninteractive

    aptitude install -y libffi5 libreadline5 libyaml-0-2 gcc
    
    cd /tmp
    wget http://repo.webbynode.com/ruby1.9.2-p180-1_amd64.deb
    dpkg -i ./ruby1.9.2-p180-1_amd64.deb
    
    update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.2 500\
                        --slave   /usr/bin/ri   ri   /usr/bin/ri1.9.2\
                        --slave   /usr/bin/irb  irb  /usr/bin/irb1.9.2\
                        --slave   /usr/bin/gem  gem  /usr/bin/gem1.9.2\
                        --slave   /usr/bin/erb  erb  /usr/bin/erb1.9.2\
                        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.2
                        
    gem update --system
    cd -
fi

if ! test -f "$chef_binary"; then
  aptitude install -y gcc
  gem install --no-rdoc --no-ri chef --version 0.10.0
  gem install --no-rdoc --no-ri ruby-shadow
fi

if ! test -d "$provisioning_folder"; then
  aptitude install -y git-core 
  git clone git://github.com/webbynode/provisioning.git
  ln -s /root/provisioning/cookbooks /root/cookbooks
  ln -s /root/provisioning/solo.json /root/solo.json
  ln -s /root/provisioning/solo.rb /root/solo.rb
fi
 
"$chef_binary" -c solo.rb -j solo.json
