# coding: utf-8
lib = File.expand_path( '../lib', __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include?( lib )

require 'apiway/version'


Gem::Specification.new do |s|

  s.name          = 'apiway'
  s.version       = Apiway::VERSION
  s.author        = '4urbanoff'
  s.email         = '4urbanoff@gmail.com'
  s.description   = 'Server side for Apiway framework'
  s.summary       = 'Framework for developing async API for web applications'
  s.homepage      = 'https://github.com/4urbanoff/rb.apiway'
  s.license       = 'MIT'

  s.files         = Dir[ 'lib/**/{*,.*}', 'bin/**/*' ] + [ 'LICENSE.txt', 'Rakefile', 'Gemfile', 'README.md' ]
  s.require_path  = 'lib'

  s.bindir        = 'bin'
  s.executables   = [ 'apiway' ]

  s.has_rdoc      = false

  s.add_dependency 'thin',                 '~> 1.6'
  s.add_dependency 'rake',                 '~> 10.3'
  s.add_dependency 'sinatra',              '~> 1.4'
  s.add_dependency 'sinatra-websocket',    '~> 0.3'
  s.add_dependency 'sinatra-activerecord', '~> 2.0'
  s.add_dependency 'sinatra-contrib',      '~> 1.4'

end
