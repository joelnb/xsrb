$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'xsrb'

Gem::Specification.new do |s|
  s.name          = 'xsrb'
  s.version       = XenStore::VERSION
  s.date          = '2016-05-13'
  s.summary       = 'Ruby XenStore API Bindings'
  s.description   = 'Pure Ruby XenStore Bindings based on pyxs (https://github.com/selectel/pyxs)'
  s.authors       = ['joelnb']
  s.homepage      = 'https://github.com/joelnb/xsrb'
  s.email         = 'joelnbarnham@gmail.com'
  s.files         = Dir.glob('{lib}/**/*')
  s.executables   = []
  s.license       = 'MIT'
  s.require_paths = ['lib']
end
