class BeforeAndAfterHooksInheritanceBase < Spinach::FeatureSteps
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

end

class BeforeAndAfterHooksInheritance < BeforeAndAfterHooksInheritanceBase
  before do
    self.class.var1 = :in_subclass
  end

  after do
    self.class.var2 = nil
  end

  Then 'I can see the variable being overridden in the subclass' do
    self.class.var1.must_equal :in_subclass
  end

  Then "I can see the variable setup in the super class before hook" do
    self.class.var2.must_equal :i_am_here
  end

end
