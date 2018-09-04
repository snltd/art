require 'date'
require 'English'

require_relative 'lib/build_helpers'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |gem|
  gem.name          = 'rdfisher'
  gem.version       = gem_version
  gem.date          = Date.today.to_s

  gem.summary       = 'Robert Fisher art website'
  gem.description   = 'Portfolio for artist Robert Fisher'
  gem.authors       = ['Robert Fisher']
  gem.email         = 'info@sysdef.xyz'
  gem.homepage      = 'https://rdfisher.co.uk'
  gem.license       = 'BSD-2-Clause'

  gem.bindir        = 'bin'
  gem.executables   = ['rdfisher.rb', 'locate_rdfisher']
  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = %w[lib]

  gem.add_runtime_dependency 'kramdown', '= 1.14.0'
  gem.add_runtime_dependency 'puma', '~> 3.11', '>= 3.11.0'
  gem.add_runtime_dependency 'sinatra', '~>2.0', '>= 2.0.1'
  gem.add_runtime_dependency 'slim', '~> 3.0', '>= 3.0.0'
  gem.add_runtime_dependency 'tilt', '~> 2.0', '>= 2.0.0'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'faraday', '~> 0.14.0'
  gem.add_development_dependency 'minitest', '~> 5.11', '>= 5.11.0'
  gem.add_development_dependency 'nokogiri', '~> 1.8', '>= 1.8.0'
  gem.add_development_dependency 'rack-test', '~> 0.8', '>= 0.8.0'
  gem.add_development_dependency 'rake', '~> 12.3', '>= 12.3.0'
  gem.add_development_dependency 'rubocop', '~> 0.52', '>= 0.52.0'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.4.0')
end
# rubocop:enable Metrics/BlockLength
