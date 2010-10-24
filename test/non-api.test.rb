require File.dirname(__FILE__) + '/_helper'

class NonApi < Test::Unit::TestCase

  verify 'can pass an instance and scope, use that id for the setting' do
    Setting.reset_all
    $sql_executor.silent_execute "insert into settings (id,name,value,scope,volatile) values (1,'a','#{ARSettings.serialize(12)}','String','f');"
    $sql_executor.silent_execute "insert into settings (id,name,value,scope,volatile) values (2,'b','#{ARSettings.serialize(13)}','String','f');"
    assert_equal 0 , Setting.scope(String).settings.size
    Setting.all.each do |db_setting|
      Setting.add_setting :record => db_setting , :scope => db_setting.scope
    end
    # assert 2 , Setting.scope(String).settings.size
    assert_equal 12 , Setting.scope(String).a
    assert_equal 13 , Setting.scope(String).b
  end

end