#encoding : utf-8

require 'mechanize'

require 'http_proxy_pool/error'
require 'http_proxy_pool/utils'
require 'http_proxy_pool/basetask'
require 'http_proxy_pool/proxy'
require 'http_proxy_pool/proxy_pool'
require 'http_proxy_pool/version'

module HttpProxyPool
  @home = File.join(Dir.home, 'http_proxy_pool')
  Dir.mkdir(@home) unless Dir.exists? @home

  @script_path = File.join(@home, 'script')
  Dir.mkdir(@script_path) unless Dir.exists? @script_path
  
  @logger = Logger.new(File.join(@home, 'proxy.log'), 2_000_000)

  init_default_script
end