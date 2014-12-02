ruby '2.1.5'

source 'https://rubygems.org'

gem 'rails', '4.2.0.rc1'

gem 'multi_json'
gem 'oj'

gem 'acts_as_list'
gem 'json-schema'
gem 'rails-html-sanitizer'
gem 'postgresql_cursor'
gem 'postrank-uri'

group :production do
  gem 'rails_12factor'
  gem 'pg'
  gem 'puma'
end

group :test do
  gem 'rake'
  gem 'mocha'
  gem 'memory_test_fix'
end

group :test, :development do
  gem 'sqlite3'
end
