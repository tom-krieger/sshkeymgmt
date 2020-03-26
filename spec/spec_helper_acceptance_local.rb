# frozen_string_literal: true

require 'puppet_litmus'
require 'singleton'

class Helper
  include Singleton
  include PuppetLitmus
end

def some_helper_method
  Helper.instance.bolt_run_script('path/to/file')
end

# @summary: Helper function to run common functionality of MOTD acceptance tests.
#           Applies the manifest twice, if not windows checks for file against expected contents.
# @param [string]  pp:                  Puppet code definition to be tested
# @param [string]  expected_contain:    Expected contents of the file to be compared
# @param [string]  filename:            file to be tested
def test_sshkeys(pp, expected_contain, filename)
  idempotent_apply(pp)

  return unless os[:family] != 'windows'
  expect(file(filename)).to be_file
  expect(file(filename)).to contain expected_contain
end
