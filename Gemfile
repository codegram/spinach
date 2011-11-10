source 'http://rubygems.org'

# Specify your gem's dependencies in spinach.gemspec
gemspec

gem 'gherkin-ruby', path: '../gherkin', require: 'gherkin'

group :test do
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-spinach'
end

group :darwin do
  gem 'rb-fsevent'
  gem 'growl'
end

group :docs do
  gem 'yard'
end
