#encoding : utf-8

module HttpProxyPool
  class ProxyPool
    attr_accessor :proxys, :logger

    def initialize(args)
      @data_path  = args[:data_path]
      @script     = args[:script]
      @logger     = args[:logger]
      @proxys     = []

      @agent      = Mechanize.new
      @agent.user_agent_alias = get_agent_alias

      load_proxy if File.exists? @data_path
    end

    # query interface
    def get_proxy(args = {})
      return get_random_proxy if args.empty?

      @proxys.select do |proxy|
        instance_eval(build_query_parameter(args,'proxy'))
      end
    end

    def build_query_parameter(args, prefix = 'proxy')
      condition_str = ''

      args.each do |key, express|
        condition_str << "#{prefix}.#{key} #{express} && "
      end

      condition_arr << '1 == 1'
    end

    def get_random_proxy
      @proxys[rand(@proxys.size)]
    end

    def vaild_condition?
    end

    def crawling
      @script.each do |site|
        begin
          site_class = instance_eval(site.capitalize!)

          site_obj = site_class.new(:agent => @agent,
                                    :logger => @logger)
          site_obj.setup if site_obj.respond_to? :setup

          site_obj.run do |fields|
            proxy = Proxy.new(fields)
            @proxys << proxy unless include?(proxy)
          end

          save_proxy
        rescue => e
          @logger.error(e)
        end
      end
    end

    def include?(proxy)
      @proxys.select{ |p| p.ip == proxy.ip}.size > 0
    end

    def save_proxy
      File.open(@data_path, 'wb') do |file|
        YAML.dump(@proxys, file)
      end
    end

    def load_proxy
      @proxys = YAML.load_file(@data_path)
    end

    def get_agent_alias
      agent_arr = [
                  'Linux Firefox',
                  'Linux Mozilla',
                  'Mac Firefox',
                  'Mac Mozilla',
                  'Mac Safari',
                  'Windows Chrome',
                  'Windows IE 7',
                  'Windows IE 8',
                  'Windows IE 9',
                  'Windows Mozilla',
                  'iPhone',
                  'iPad',
                  'Android']

      agent_arr[rand(agent_arr.size)]                    
    end
  end
end