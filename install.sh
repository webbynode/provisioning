#!/bin/bash
 
# This runs on the server
 
chef_binary=/var/lib/gems/1.9.2/bin/chef-solo
 
# Are we on a vanilla system?
if ! test -f "$chef_binary"; then
    export DEBIAN_FRONTEND=noninteractive

    aptitude install -y libffi5 libreadline5 libyaml-0-2
    
    cd /tmp
    wget http://repo.webbynode.com/ruby1.9.2-p180-1_amd64.deb
    dpkg -i ./ruby1.9.2-p180-1_amd64.deb
    
    update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.2 500\
                        --slave   /usr/bin/ri   ri   /usr/bin/ri1.9.2\
                        --slave   /usr/bin/irb  irb  /usr/bin/irb1.9.2\
                        --slave   /usr/bin/gem  gem  /usr/bin/gem1.9.2\
                        --slave   /usr/bin/erb  erb  /usr/bin/erb1.9.2\
                        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.2
fi &&
 
"$chef_binary" -c solo.rb -j solo.json