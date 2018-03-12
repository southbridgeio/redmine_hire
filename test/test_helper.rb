# Load the Redmine helper
$VERBOSE = nil

require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', [:issues, :projects, :trackers, :issue_statuses, :issue_priorities])

require 'webmock/minitest'
require 'mocha/mini_test'
