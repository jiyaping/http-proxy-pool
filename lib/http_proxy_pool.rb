#encoding : utf-8

require 'mechanize'
require 'yaml'
require 'logger'

require 'http_proxy_pool/proxy_pool'
require 'http_proxy_pool/version'

module HttpProxyPool
  @home = File.join(Dir.home, 'http_proxy_pool')
  Dir.mkdir(@home) unless Dir.exists? @home

  @logger = logger

  @script_path = File.join(@home, 'script')
  Dir.mkdir(@script_path) unless Dir.exists? @script_path
  save_default_script

  @execute_script = Dir.entries(@script_path).select{ |item| !(item == '.' and item == '..') }
  load_script

  def self.save_default_script
    target_dir = Dir.new(@script_path)

    src_dir = "#{__FILE__}/http_proxy_pool/example"
    Dir.entries(src_dir) do |src|
      FileUtils.cp File.join(src_dir, src), src.path unless target_dir.include? src
    end
  end

  def self.load_script
    Dir.entries(@script_path).each do |item|
      next if ( item == '.' || item == '..' )

      item = item.sub('.rb', '') if item.end_with? '.rb'
      require "#{script_path}/#{item}"
    end
  end

  def self.home
    @home
  end

  def self.script_path
    @script_path
  end

  def self.execute_script
    @execute_script
  end

  def self.logger
    @logger || Logger.new(File.join(@home, 'proxy.log'), 2_000_000)
  end
end
