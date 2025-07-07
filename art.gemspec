# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name          = 'art'
  gem.version       = ENV.fetch('RELEASE_VERSION',
                                "0.0.#{Time.now.strftime('%Y%m%d')}")

  gem.summary       = "Art website"
  gem.description   = 'Portfolio website'
  gem.authors       = ['sysdef']
  gem.email         = 'info@sysdef.xyz'
  gem.homepage      = 'https://art.id264.net'
  gem.license       = 'BSD-2-Clause'

  gem.bindir        = 'bin'
  gem.executables   = %w[art.rb]
  gem.files         = Dir['sections/**/*', 'bin/art.rb', 'art.gemspec',
                          'config.ru', 'Gemfile*', 'lib/**/*', 'public/**/*',
                          'views/**/*', 'Rakefile', 'robots.txt']
  gem.require_paths = %w[lib]

  gem.required_ruby_version = Gem::Requirement.new('>= 3.4.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
