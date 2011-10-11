# About Spinach
Spinach is a BDD framework for ruby on top of gherkin. Its main goals are:

* *Step reusability*: All the steps of a feature live in a common class space.
* *Step maintainability*: Since feature steps are just classes, you can use the
  good practices you already know about ruby.
* *Easy to use and to understand*: Spinach's codebase is well-written and
  well-documented - there's no magic involved.

# Compatibility

Spinach is tested against MRI 1.9.2-1.9.3. We're working to make it compatible
with as many implementations as possible. Rubinius 2.0 support is in the way.

We're not planning to make it compatible with 1.8.7 since, you know, this would
be irresponsible :).

# Getting started

Just add spinach in your Gemfile:

````ruby

  group :test do
    gem 'minitest', require: 'minitest/spec'
    gem 'spinach'
  end

````

Then, create a `features` folder in your app and write in your first feature:

````
  # features/test_how_spinach_works.feature

  Feature: Test how spinach works
    In order to know what the heck is spinach
    As a developer
    I want it to behave in an expected way

    Scenario: Formal salutation
      Given I have an empty array
      And I append my first name and my last name to it
      When I pass it to my super-duper method
      Then the output should contain a formal salutation

    Scenario: Informal salutacion
      Given I have an empty array
      And I append only my first name to it
      When I pass it to my super-duper method
      Then the output should contain a casual salutation

````

Just run `spinach --generate` and it will create a corresponding
`features/steps/test_how_spinach_works.rb` that looks like the following:

````ruby

  Feature 'Test how spinach works' do
    Given 'I have an empty array' do
    end

    And 'I append my first name and my last name to it' do
    end

    When 'I pass it to my super-duper method' do
    end

    Then 'the output should contain a formal salutation' do
    end

    And 'I append only my first name to it' do
    end

    Then 'the output should contain a casual salutation' do
    end
  end

````

Then, you can fill it in with your logic - remember, it's just a class, you can
use private methods, mix in modules or whatever!

````ruby

  Feature 'Test how spinach works' do
    Given 'I have an empty array' do
      @array = Array.new
    end

    And 'I append my first name and my last name to it' do
      @array += ["John", "Doe"]
    end

    When 'I pass it to my super-duper method' do
      @output = capture_output do
        SalutationMachine.salutate(@array)
      end
    end

    Then 'the output should contain a formal salutation' do
      @output.must_include "Hello, mr. John Doe"
    end

    And 'I append only my first name to it' do
      @array += ["John"]
    end

    Then 'the output should contain a casual salutation' do
      @output.must_include "Yo, John! Whassup?"
    end

    private

    def capture_output
      out = StreamIO.new
      $stdout = out
      $stderr = out
      yield
      $stdout = STDOUT
      $stderr = STDERR
      out.string
    end
  end


````

Then run your feature again using `spinach` and watch it all be green! :)


# Documentation
[Spinach documentation at rubydoc.info](http://rubydoc.info/github/codegram/spinach/master/frames)


# Build status
[![Build Status](https://secure.travis-ci.org/codegram/spinach.png)](http://travis-ci.org/codegram/spinach)
