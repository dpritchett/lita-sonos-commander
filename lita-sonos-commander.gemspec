Gem::Specification.new do |spec|
  spec.name          = 'lita-sonos-commander'
  spec.version       = '1.1.2'
  spec.authors       = ['Daniel J. Pritchett']
  spec.email         = ['dpritchett@gmail.com']
  spec.description   = 'Control your Sonos with Lita chatbot commands'
  spec.summary       = 'Control your Sonos with Lita chatbot commands'
  spec.homepage      = 'https://github.com/dpritchett/lita-sonos-commander'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # START:runtime_dependency
  spec.add_runtime_dependency 'lita', '>= 4.7'
  spec.add_runtime_dependency 'faye-websocket', '~> 0.10.7'
  # END:runtime_dependency

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'coveralls'
end
