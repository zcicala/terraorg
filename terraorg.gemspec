require 'date'
require File.expand_path(File.join('lib', 'terraorg', 'version.rb'))

Gem::Specification.new do |gem|
  gem.name    = 'terraorg'
  gem.version = Terraorg::VERSION
  gem.date    = Date.today.to_s

  gem.summary = "terraorg"
  gem.description = "Manage an organizational structure with Okta and G-Suite using Terraform"

  gem.authors  = ['Joshua Kwan']
  gem.email    = 'joshk@triplehelix.org'
  gem.homepage = 'https://github.com/LiveRamp/terraorg'
  gem.license  = 'MIT'

  gem.required_ruby_version = '>= 2.3'

  gem.add_dependency 'faraday'
  gem.add_dependency 'neatjson'
  gem.add_dependency 'oktakit'

  # ensure the gem is built out of versioned files
  gem.files = Dir['{bin,lib}/**/*', 'README*', 'LICENSE*']
  gem.executables = ['terraorg']
  gem.require_paths = ['lib']
end
