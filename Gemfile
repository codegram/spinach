source 'http://rubygems.org'

# Specify your gem's dependencies in spinach.gemspec
gemspec

gem 'rake'
gem 'coveralls', require: false

group :test do
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-spinach'
  gem 'capybara', '~> 2.0.0'
  gem "rspec"
  gem 'fakefs'
end

group :darwin do
  gem 'rb-fsevent'
  gem 'growl'
end

group :docs do
  gem 'yard'
end
