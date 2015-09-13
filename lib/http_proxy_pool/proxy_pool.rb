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

    def unused_proxy(minutes)
      
    end

    # query interface
    def get_proxy(args = {})
      return get_random_proxy if args.empty?

      @proxys.select do |proxy|
        instance_eval(build_query_parameter(args,'proxy'))
      end
    end

    def status
      puts "proxy count : #{@proxys.size}"
    end

    def build_query_parameter(args, prefix = 'proxy')
      condition_str = ''

      args.each do |key, express|
        condition_str << "#{prefix}.#{key} #{express} && "
      end

      @logger.debug(condition_arr)

      condition_arr << '1 == 1'
    end

    def get_random_proxy(check = true)
      begin
        loop do
          proxy = @proxys[rand(@proxys.size)]
          @logger.info("using #{proxy}.")
          proxy = checker(proxy) if check

          return proxy if proxy.is_a? Proxy
        end
      ensure
        save_proxy
      end
    end

    def vaild_condition?
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
            puts @proxys.size
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

    def checker(proxy)
      if proxy.is_a? Array
        return checker_batch(proxy)
      else
        return checker_single(proxy)
      end
    end

    def checker_batch(proxys, task_count = 5)
      result = []
      mutex = Mutex.new
      thread_count = (proxys / task_count.to_f).ceil

      thread_count.times do |thread_idx|
        Thread.new do
          start_idx = thread_idx * task_count
          end_idx = (thread_idx * task_count > proxys.size ? proxys.size : thread_idx * task_count)

          proxys[start_idx..end_idx].each do |proxy|
            p = checker_single(proxy)
            mutex.synchronize  do
              result<< p if p
            end
          end
        end.join
      end
    end

    def checker_single(proxy, timeout = 0.05)
      http = Net::HTTP.new('baidu.com', 80, proxy.ip, proxy.port)
      http.open_timeout = timeout
      http.read_timeout = timeout

      begin
        return proxy if http.get('/').code =~ /^[1|2|3|4]/
      rescue => e
        @logger.info("can not connect proxy.[#{proxy}].#{e.to_s}")
        @proxys.delete(proxy)
        @logger.info("delete proxy :[#{proxy}]")
      end
    end
  end
end