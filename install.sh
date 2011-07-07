#!/bin/bash
 
ruby_binary=/usr/bin/ruby1.9.2
chef_binary=/usr/bin/chef-solo
solo_rb=/var/webbynode/chef/solo.rb
solo_json=/var/webbynode/chef/provision.json
chef_folder=/var/webbynode/chef
provisioning_folder=$chef_folder/chef/provisioning

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
  cd $chef_folder
  aptitude install -y git-core 
  git clone git://github.com/webbynode/provisioning.git
  ln -s /$provisioning_folder/cookbooks /$chef_folder/cookbooks
  ln -s /$provisioning_folder/provision.json /$chef_folder/provision.json
  ln -s /$provisioning_folder/solo.rb /$chef_folder/solo.rb
fi
 
cd $chef_folder
"$chef_binary" -c solo.rb -j /$chef_folder/provision.json
