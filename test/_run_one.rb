#!/usr/bin/env ruby
query = File.dirname(__FILE__) << '/*_test.rb'
Dir[query].each { |filename| require filename }