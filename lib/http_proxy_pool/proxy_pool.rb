# encoding : utf-8

module HttpProxyPool
  class Proxy
    attr_accessor :ip,
                  :port
                  :username,
                  :password,
                  :proxy_level,
                  :proxy_type,
                  :speed,
                  :added_time,
                  :last_access_time,
                  :nation,
                  :province,
                  :src_from

    def initialize(args)
      @ip         = args[:ip]
      @port       = args[:port]
      @username   = args[:username] || ''
      @password   = args[:password] || ''
      @proxy_type = args[:proxy_type]
      @proxy_level= args[:proxy_level]
      @speed      = args[:speed]
      @added_time = args[:added_time]
      @last_access= args[:last_access]
      @area       = args[:area]
      @src_from   = args[:src_from]
      @try_times  = args[:try_times] || 0
    end

    def to_arr
      [@ip, @port, @proxy_type, @proxy_level, @nation, @province]
    end
  end

  class ProxyPool
    attr_accessor :proxys, :config, :logger

    def initialize(args)
      @data_path  = args[:data_path]
      @script     = args[:script]
      @logger     = args[:logger] || HttpProxyPool.logger
      @proxys     = []

      @agent      = Mechanize.new
      @agent.user_agent_alias = get_agent_alias

      load_proxy if File.join(@data_path, '')
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
          site = instance_eval(site.capitalize!)

          site.new.run do |fields|
            proxy = Proxy.new(fileds)
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
      YAML.load_file(@data_path, 'wb')
    end

    def get_agent_alias
      agent_arr = [
                  'Linux Firefox',
                  'Linux Konqueror',
                  'Linux Mozilla',
                  'Mac Firefox',
                  'Mac Mozilla',
                  'Mac Safari 4',
                  'Mac Safari',
                  'Windows Chrome',
                  'Windows IE 6',
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