#encoding : utf-8

Gem::Specification.new do |s|
  s.authors     = ['jiyaping']
  s.email       = 'jiyaping0802@gmail.com'
  s.homepage    = 'https://github.com/jiyaping/http-proxy-pool'

  s.name	      = 'http_proxy_pool'
  s.version	    = '0.0.2'
  s.license     = 'MIT'
  s.executables	<< 'proxypool'
  s.date	      = '2015-09-06'
  s.summary	    = 'http proxy crawling from web'
  s.description	= 'Gather free http proxy data'
  
  s.files	= Dir['{bin,lib/**/*}'] + %w[Rakefile README.md]
  
  s.add_runtime_dependency 'mechanize', '~> 2.7'
end