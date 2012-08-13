class BeforeAndAfterHooks < Spinach::FeatureSteps
  class << self
    attr_accessor :var1
    attr_accessor :var2
  end

  before do
    if self.class.var2.nil?
      self.class.var2 = :i_am_here
    else
      self.class.var2 = :dirty
    end
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
