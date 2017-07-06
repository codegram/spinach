require_relative '../test_helper'

describe Spinach::Config do
  subject do
    Spinach::Config.new
  end

 describe '#features_path' do
   it 'returns a default' do
     subject[:features_path].must_be_kind_of String
   end

   it 'can be overwritten' do
     subject[:features_path] = 'test'
     subject[:features_path].must_equal 'test'
   end
 end

 describe '#reporter_classes' do
   it 'returns a default' do
     subject[:reporter_classes].must_equal ["Spinach::Reporter::Stdout"]
   end

   it 'can be overwritten' do
     subject[:reporter_classes] = ["MyOwnReporter"]
     subject[:reporter_classes].must_equal ["MyOwnReporter"]
   end
 end

 describe '#step_definitions_path' do
   it 'returns a default' do
     subject[:step_definitions_path].must_be_kind_of String
   end

   it 'can be overwritten' do
     subject[:step_definitions_path] = 'steps'
     subject[:step_definitions_path].must_equal 'steps'
   end
 end

 describe '#support_path' do
   it 'returns a default' do
     subject[:support_path].must_be_kind_of String
   end

   it 'can be overwritten' do
     subject[:support_path] = 'support'
     subject[:support_path].must_equal 'support'
   end
 end

 describe '#failure_exceptions' do
   it 'returns a default' do
     subject[:failure_exceptions].must_be_kind_of Array
   end

   it 'can be overwritten' do
     subject[:failure_exceptions] = [1, 2, 3]
     subject[:failure_exceptions].must_equal [1,2,3]
   end

   it 'allows adding elements' do
     subject[:failure_exceptions] << RuntimeError
     subject[:failure_exceptions].must_include RuntimeError
   end
 end

 describe '#config_path' do
   it 'returns a default' do
     subject[:config_path].must_equal 'config/spinach.yml'
   end

   it 'can be overwritten' do
     subject[:config_path] = 'my_config_file.yml'
     subject[:config_path].must_equal 'my_config_file.yml'
   end
 end

 describe '#parse_from_file' do
   before do
     subject[:config_path] = 'a_path'
     YAML.stubs(:load_file).returns({support_path: 'my_path', config_path: 'another_path'})
     subject.parse_from_file
   end

   it 'sets the options' do
     subject[:support_path].must_equal 'my_path'
   end

   it "doesn't set the config_path option" do
     subject[:config_path].must_equal 'a_path'
   end
 end

 describe '#tags' do
   it 'returns a default' do
     subject[:tags].must_be_kind_of Array
   end

   it 'can be overwritten' do
     subject[:tags] = ['wip']
     subject[:tags].must_equal ['wip']
   end
 end
end
