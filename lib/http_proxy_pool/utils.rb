#encoding : utf-8

module HttpProxyPool
  module_function

  def init_default_script
    
    target_dir = Dir.new(@script_path)

    src_dir = File.join(File.dirname(__FILE__), 'example')
    Dir.entries(src_dir).each do |src|
      next if ( src == '.' || src == '..' )

      FileUtils.cp File.join(src_dir, src), target_dir.path unless target_dir.include? src
    end
  end

  def load_script
    Dir.entries(@script_path).each do |item|
      next if ( item == '.' || item == '..' )

      item = item.sub('.rb', '') if item.end_with? '.rb'
      require File.join(@script_path, item)
    end
  end

  def home
    @home
  end

  def script_path
    @script_path
  end

  def execute_script
    Dir.entries(@script_path).select{ |item| !(item == '.' or item == '..') }.map do |item|
      item.sub('.rb', '') if item.end_with? '.rb'
    end
  end

  def logger
    @logger
  end
end