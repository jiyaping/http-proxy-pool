#encoding : utf-8

module HttpProxyPool
  class ProxyPool
    attr_accessor :proxys, :logger

    def initialize(args = {})
      @data_path  = args[:data_path] || File.join(HttpProxyPool.home, 'ips.yaml')
      @script     = args[:script]    || Dir["#{HttpProxyPool.home}/script/*.site"]
      @logger     = args[:logger]    || HttpProxyPool.logger
      @proxys     = []

      @agent      = Mechanize.new
      @agent.user_agent_alias = get_agent_alias

      load_proxy if File.exists? @data_path
    end

    def status
      puts "proxy count : #{@proxys.size}"
    end

    # query interface
    def query(args = {})
      begin
        selected_proxy = @proxys.select do |proxy|
                            if args.size > 0
                              instance_eval(build_query_parameter('proxy', args))
                            else
                              true
                            end
                         end
      rescue => e
        raise QueryError.new("query parameter error!")
      end

      return selected_proxy unless block_given?

      selected_proxy.each do |proxy|
        yield proxy
      end
    end

    def build_query_parameter(prefix = 'proxy', args)
      condition_str = ''

      args = query_key_filter(args)

      args.each do |key, express|
        condition_str << "#{prefix}.#{key} #{express} && "
      end

      condition_str.sub!(/\s?&&\s?$/, '')

      condition_str
    end

    def query_key_filter(args)
      proxy = Proxy.new
      args.select{ |k| proxy.respond_to? k }
    end

    def get_random_proxy(check = true, thread_num = 10)
      mutex       = Mutex.new
      result      = nil
      thread_list = []

      begin
        thread_num.times do |thread|
          thread_list  << Thread.new do
                            while(!result)
                              proxy = @proxys[rand(@proxys.size)]
                              @logger.info("using #{proxy}.")
                              proxy = checker(proxy) if check

                              if proxy.is_a? Proxy
                                mutex.synchronize do
                                  result = proxy
                                end
                              end
                            end
                          end
        end

        thread_list.each { |t| t.join }
      rescue => e
        @logger.error("find proxy error. #{e.to_s}")
      ensure
        save_proxy
      end

      result
    end

    def crawling(lastest = true, check = false)
      @script.each do |file|
        begin
          task = Basetask.new(:agent => @agent,:logger => @logger)
          task.instance_eval(read_taskfile(file))

          task.ips(lastest) do |fields|
            proxy = Proxy.new(fields)
            (next unless checker(proxy)) if check
            @proxys << proxy unless include?(proxy)
          end
        rescue => e
          @logger.error(e)
        ensure
          save_proxy
        end
      end
    end

    def include?(proxy)
      @proxys.select{ |p| p.ip == proxy.ip}.size > 0
    end

    def save_proxy
      file = File.open(@data_path, 'w')
      YAML.dump(@proxys, file)
      file.close
    end

    def load_proxy
      @proxys = YAML.load_file(@data_path)
    end

    def read_taskfile(file)
      cnt = ''
      File.open(file) do |f|
        while(line = f.gets)
          cnt << line
        end
      end

      cnt
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

    def checker(proxy, args = {})
      args[:task_count] ||= 5
      args[:timeout]    ||= 0.05

      if proxy.is_a? Array
        checker_batch(proxy, args)
      else
        checker_single(proxy, args[:timeout])
      end
    end

    def checker_batch(proxys, args = {})
      args[:task_count] ||= 5
      args[:timeout]    ||= 0.05

      result  = []
      mutex   = Mutex.new
      thread_count = (proxys.size / args[:task_count].to_f).ceil
      threads = []

      thread_count.times do |thread_idx|
        threads <<Thread.new do
                    start_idx = thread_idx * args[:task_count]
                    end_idx   = (thread_idx + 1) * args[:task_count]

                    end_idx   = proxys.size if end_idx > proxys.size

                    proxys[start_idx..end_idx].each do |proxy|
                      p = checker_single(proxy, args[:timeout])

                      mutex.synchronize  do
                        if p
                          result<< p 
                        else
                          @proxys.delete(p)
                        end
                      end
                    end
                  end
      end

      threads.each { |t| t.join }
      save_proxy

      result
    end

    def checker_single(proxy, timeout = 0.05)
      http = Net::HTTP.new('baidu.com', 80, proxy.ip, proxy.port)
      http.open_timeout = timeout
      http.read_timeout = timeout * 10

      begin
        return proxy if http.get('/').code =~ /^[1|2|3|4]/
      rescue => e
        @logger.info("can not connect proxy.[#{proxy}].#{e.to_s}")
        @proxys.delete(proxy)
        @logger.info("delete disabled proxy [#{proxy}].")
      end

      nil
    end
  end
end