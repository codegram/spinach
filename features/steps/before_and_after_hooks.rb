class BeforeAndAfterHooks < Spinach::FeatureSteps
  class << self
    attr_accessor :var1
  end

  before do
    if self.class.var1.nil?
      self.class.var1 = :clean
    else
      self.class.var1 = :dirty
    end
  end

  after do
    self.class.var1 = nil
  end

  Then 'I can verify the variable setup in the before hook' do
    self.class.var1.must_equal :clean
  end
end
