module Spinach
  def self.config
    @config ||= Config.new
  end
  class Config
    attr_writer :step_definitions_path
    def step_definitions_path
      @step_definitions_path || 'features/steps'
    end
    def [](attribute)
      self.send(attribute)
    end
    def []=(attribute, params)
      self.send("#{attribute}=", params)
    end
  end
end
