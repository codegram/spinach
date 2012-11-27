source 'http://rubygems.org'

# Specify your gem's dependencies in spinach.gemspec
gemspec

gem 'rake'

group :test do
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-spinach'
  gem 'capybara', '~> 1.1.3'
end

group :darwin do
  gem 'rb-fsevent'
  gem 'growl'
end

group :docs do
  gem 'yard'
end
