require_relative "before_and_after_hooks"
class BeforeAndAfterHooksInheritance < BeforeAndAfterHooks
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
