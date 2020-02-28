#!/bin/bash

bundle exec rake 'litmus:provision[docker, centos:7]'
bundle exec rake 'litmus:provision[docker, ubuntu:18.04]'

bundle exec rake litmus:install_agent
bundle exec rake litmus:install_module

#bundle exec rake litmus:acceptance:parallel 

TARGET_HOST=localhost:2222 bundle exec rspec ./spec/acceptance --format d
TARGET_HOST=localhost:2223 bundle exec rspec ./spec/acceptance --format d

bundle exec rake litmus:tear_down
