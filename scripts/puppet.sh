#!/bin/sh -eux

# Install Puppet Agent
/bin/dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
/bin/dnf -y install https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm
/bin/dnf -y install puppet-agent

# Install Puppet gem addons 
/opt/puppetlabs/puppet/bin/gem install xml-simple toml toml-rb
