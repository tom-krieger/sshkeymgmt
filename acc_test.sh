#!/bin/bash

# install all needed gems locally
# bundle install --path .bundle/gems/

# fire up two docker containers
bundle exec rake 'litmus:provision[docker, centos:7]'
bundle exec rake 'litmus:provision[docker, ubuntu:18.04]'

# install Puppet agent
bundle exec rake litmus:install_agent

# install Puppet module to test
bundle exec rake litmus:install_module

# run tests in parallel with less output
#bundle exec rake litmus:acceptance:parallel 

# run tests with more output
TARGET_HOST=localhost:2222 bundle exec rspec ./spec/acceptance --format d
TARGET_HOST=localhost:2223 bundle exec rspec ./spec/acceptance --format d

# tear down the test environment
bundle exec rake litmus:tear_down

exit 0
