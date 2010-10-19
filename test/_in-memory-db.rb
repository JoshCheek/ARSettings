require 'rubygems'
require 'sqlite3'
require 'active_record'



# require the setting lib that we will be testing
require File.dirname(__FILE__) + '/../lib/arsettings'



# hook it up to an in memory sqlite3 db
ActiveRecord::Base.establish_connection :adapter => 'sqlite3' , :database => ":memory:" 

class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string  :name  , :null => false , :size => 30
      t.text    :value
      t.timestamps
    end
  end
end



# silently perform the migration
require 'stringio'
$stdout = StringIO.new
CreateSettings.migrate :up
$stdout = STDOUT
