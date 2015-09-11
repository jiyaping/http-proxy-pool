#encoding : utf-8

module HttpProxyPool
  module_function

  def init_default_script
    
    target_dir = Dir.new(@script_path)

    src_dir = File.join(File.dirname(__FILE__), 'example')
    Dir.entries(src_dir).each do |src|
      next unless src.end_with? '.site'

      FileUtils.cp File.join(src_dir, src), target_dir.path unless target_dir.include? src
    end
  end

  def home
    @home
  end

  def script_path
    @script_path
  end

  def logger
    @logger
  end
end