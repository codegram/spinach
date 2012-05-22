# Spinach - BDD framework on top of Gherkin [![Build Status](https://secure.travis-ci.org/codegram/spinach.png)](http://travis-ci.org/codegram/spinach) [![Dependency Status](https://gemnasium.com/codegram/spinach.png)](http://gemnasium.com/codegram/spinach)

Spinach is a high-level BDD framework that leverages the expressive
[Gherkin language][gherkin] (used by [Cucumber][cucumber]) to help you define
executable specifications of your application or library's acceptance criteria.

Conceived as an alternative to Cucumber, here are some of its design goals:

* Step maintanability: since features map to their own classes, their steps are
  just methods of that class. This encourages step encapsulation.

* Step reusability: In case you want to reuse steps across features, you can
  always wrap those in plain ol' Ruby modules.

Spinach is tested against MRI 1.9.2, 1.9.3. Rubinius 2.0 support is on the
works.

We are not planning to make it compatible with MRI 1.8.7 since, you know, this
would be irresponsible :)

## Getting started

Start by adding spinach to your Gemfile:

    group :test do
      gem 'spinach'
      # gem 'rspec'
    end

Spinach works out-of-the-box with your favorite test suite, but you can also
use it with RSpec as well if you put the following in `features/support/env.rb`:

    require 'rspec'

Now create a `features` folder in your app or library and write your first
feature:

    Feature: Test how spinach works
      In order to know what the heck is spinach
      As a developer
      I want it to behave in an expected way

      Scenario: Formal greeting
        Given I have an empty array
        And I append my first name and my last name to it
        When I pass it to my super-duper method
        Then the output should contain a formal greeting

      Scenario: Informal greeting
        Given I have an empty array
        And I append only my first name to it
        When I pass it to my super-duper method
        Then the output should contain a casual greeting

Now for the steps file. Remember that in Spinach steps are just Ruby classes,
following a camelcase naming convention. Spinach generator will do some
scaffolding for you:

    $ spinach --generate

Spinach will detect your features and generate the following class:

## features/steps/test_how_spinach_works.rb

    class TestHowSpinachWorks < Spinach::FeatureSteps
      Given 'I have an empty array' do
      end

      And 'I append my first name and my last name to it' do
      end

      When 'I pass it to my super-duper method' do
      end

      Then 'the output should contain a formal greeting' do
      end

      And 'I append only my first name to it' do
      end

      Then 'the output should contain a casual greeting' do
      end
    end

Then, you can fill it in with your logic - remember, it's just a class, you can
use private methods, mix in modules or whatever!

    class TestHowSpinachWorks < Spinach::FeatureSteps
      Given 'I have an empty array' do
        @array = Array.new
      end

      And 'I append my first name and my last name to it' do
        @array += ["John", "Doe"]
      end

      When 'I pass it to my super-duper method' do
        @output = capture_output do
          Greeter.greet(@array)
        end
      end

      Then 'the output should contain a formal greeting' do
        @output.must_include "Hello, mr. John Doe"
      end

      And 'I append only my first name to it' do
        @array += ["John"]
      end

      Then 'the output should contain a casual greeting' do
        @output.must_include "Yo, John! Whassup?"
      end

      private

      def capture_output
        out = StringIO.new
        $stdout = out
        $stderr = out
        yield
        $stdout = STDOUT
        $stderr = STDERR
        out.string
      end
    end
    module Greeter
      def self.greet(name)
        if name.length > 1
          puts "Hello, mr. #{name.join(' ')}"
        else
          puts "Yo, #{name.first}! Whassup?"
        end
      end
    end

Then run your feature again running `spinach` and watch it all turn green! :)

## Tags

Feature and Scenarios can be marked with tags in the form: `@tag`. Tags can be
used for different purposes:

- applying some actions using hooks (eg: `@javascript`, `@transaction`, `@vcr`)

        # When using Capybara, you can switch the driver to use another one with
        # javascript capabilities (Selenium, Poltergeist, capybara-webkit, ...)
        #
        # Spinach already integrates with Capybara if you add
        # `require spinach/capybara` in `features/support/env.rb`.
        #
        # This example is extracted from this integration.
        Spinach.hooks.on_tag("javascript") do
          ::Capybara.current_driver = ::Capybara.javascript_driver
        end

- filtering (eg: `@module-a`, `@customer`, `@admin`, `@bug-12`, `@feat-1`)

        # Given a feature file with this content

        @feat-1
        Feature: So something great

          Scenario: Make it possible

          @bug-12
          Scenario: Ensure no regression on this

  Then you can run all Scenarios in your suite related to `@feat-1` using:

        spinach --tags @feat-1

  Or only Scenarios related to `@feat-1` and `@bug-12` using:

        spinach --tags @feat-1,@bug-12

  Or only Scenarios related to `@feat-1` excluding `@bug-12` using:

        spinach --tags @feat-1,~@bug-12

By default Spinach will ignore Scenarios marked with the tag `@wip` or whose
Feature is marked with the tag `@wip`. Those are meant to be work in progress,
scenarios that are pending while you work on them. To explicitly run those, use
the `--tags` option:

    spinach --tags @wip

## Hook architecture

Spinach provides several hooks to allow you performing certain steps before or
after any feature, scenario or step execution.

So, for example, you could:

    Spinach.hooks.before_scenario do |scenario|
      clear_database
    end

    Spinach.hooks.on_successful_step do |step, location|
      count_steps(step.scenario.steps)
    end

    Spinach.hooks.after_run do |status|
      send_mail if status == 0
    end

Full hook documentation is here:

[Spinach's hook documentation on rubydoc](http://rubydoc.info/github/codegram/spinach/master/Spinach/Hooks)

## Wanna use it with Rails 3?

Use [spinach-rails](http://github.com/codegram/spinach-rails)

## Other rack-based frameworks

Check out our [spinach-sinatra demo](https://github.com/codegram/spinach-sinatra-demo)

## Resources

* [Landing page](http://codegram.github.com/spinach)
* [Slides](http://codegram.github.com/spinach-presentation)
* [Blog post](http://blog.codegram.com/2011/10/how-to-achieve-more-clean-encapsulated-modular-step-definitions-with-spinach)
* [API Documentation](http://rubydoc.info/github/codegram/spinach/master/frames)
* [Google group](https://groups.google.com/forum/#!forum/spinach_bdd)

### Related gems

* [guard-spinach](http://github.com/codegram/guard-spinach)
* [spinach-rails](http://github.com/codegram/spinach-rails)

### Demos

* [spinach rails demo](https://github.com/codegram/spinach-rails-demo)
* [spinach sinatra demo](https://github.com/codegram/spinach-sinatra-demo)
* [simple todo Rails app](https://github.com/codegram/tasca-spinach-demo)

## Contributing

* [List of spinach contributors](https://github.com/codegram/spinach/contributors)

You can easily contribute to Spinach. Its codebase is simple and
[extensively documented][documentation].

* Fork the project.
* Make your feature addition or bug fix.
* Add specs for it. This is important so we don't break it in a future
  version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  If you want to have your own version, that is fine but bump version
  in a commit by itself I can ignore when I pull.
* Send me a pull request. Bonus points for topic branches.

[gherkin]: http://github.com/codegram/gherkin-ruby
[cucumber]: http://github.com/cucumber/cucumber
[documentation]: http://rubydoc.info/github/codegram/spinach/master/frames

## License

MIT License. Copyright 2011 [Codegram Technologies](http://codegram.com)

