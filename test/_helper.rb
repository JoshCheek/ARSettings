# require libs and gems
require 'test/unit'
require File.dirname(__FILE__) << "/_in-memory-db"

ARSettings.create_settings_class 'Setting'

# monkey patch Test::Unit::TestCase to make it easier to work with
class Test::Unit::TestCase
  
  # some dummy classes for use with test data
  Example1 = Struct.new :a , :b

  Example2 = Class.new do 
    attr_accessor :a , :b
    def initialize(a,b)
      @a,@b = a,b
    end
    def ==(ex2)
      @a == ex2.a && 
      @b == ex2.b
    end
  end
  
  def object_menagerie
    [ 'a' , :a , 1 , /a/ , [1,2] , true , false , nil , {:a => 1,:b => 2} , Example1.new(1,2) , Example2.new(1,2) ]
  end
  
  def self.to_method_name(str)
    str.gsub(/\s+/,'_').gsub(/\W+/,'')
  end
  
  def self.context(context)
    @context = to_method_name(context)
    yield
    @context = nil
  end
  
  def self.verify( to_verify , &verification )
    prefix = "test_"
    prefix << @context << '_' if @context && !@context.empty?
    define_method prefix << to_method_name(to_verify) , &verification if verification
  end

  def assert_invalid(&block)
    assert_raises ActiveRecord::RecordInvalid , &block
  end
  
  def assert_invalid_name(&block)
    assert_raises Setting::InvalidName , &block
  end
  
  def assert_count(count)
    assert_equal count , Setting.count
  end
    
end
