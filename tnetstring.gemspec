$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__)).uniq!
require "tnetstring/version"

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'tnetstring'
  s.version     = TNetstring::Version::STRING
  s.summary     = "Ruby implementation of the typed netstring specification."
  s.description = "Ruby implementation of the typed netstring specification, a simple data interchange format better suited to low-level network communication than JSON. See http://tnetstrings.org/ for more details."

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.7"

  s.files = Dir['lib/**/*']

  s.author            = 'Matt Yoho'
  s.email             = 'mby@mattyoho.com'
  s.homepage          = 'http://github.com/mattyoho/tnetstring-rb'

  s.add_development_dependency('rspec', '~> 2.5.0')
  s.add_development_dependency('bundler', '>= 1.0.12')
end
