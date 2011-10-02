require 'aruba/api'

module Integration
  module SpinachRunner
    include Aruba::Api

    private
    def run_feature(command, options=nil)
      run "../../bin/spinach #{command} #{options}"
    end
  end
end
