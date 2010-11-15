require 'rubygems'
require 'sqlite3'
require 'active_record'

# hook up an in memory sqlite3 db
ActiveRecord::Base.establish_connection :adapter => 'sqlite3' , :database => ":memory:" 


# silently create the db
require 'stringio'
$stdout = StringIO.new

ActiveRecord::Schema.define do
  create_table :settings do |t|
    t.string  :name     , :null => false , :size => 30
    t.text    :value
    t.text    :package
    t.boolean :volatile , :default => false
    t.timestamps
  end
  
  create_table :users do |t|
    t.string :name
  end
end

$stdout = STDOUT
