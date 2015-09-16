#encoding : utf-8

module HttpProxyPool
  class Voyager
    PORTS          = '80,8080,3128,8081,9080,1080,443,8888,8118,8088,8123,3128'
    IPV4_LEN       = 32

    attr_accessor :proxy_pool

    def initialize(pool)
      @proxy_pool = pool
    end

    def start(ips, thread_num, ports = nil)
      ports   ||= PORTS

      ports_arr = port_list(ports)
      ip        = parser_ips(ips)

      dispatcher(ip, thread_num, ports_arr)
    end

    def dispatcher(ip, thread_num, ports)
      ip_start = ip.to_range.begin.to_i
      ip_end   = ip.to_range.end.to_i

      task_count = ((ip_end - ip_start) / thread_num.to_f).ceil
      threads  = []
      thread_num.times do |t_idx|
        threads<< Thread.new do
                    t_ip_start = t_idx * task_count + ip_start
                    t_ip_end   = (t_idx + 1) * task_count - 1 + ip_start

                    t_ip_end   = ip_end if t_ip_end > ip_end

                    t_ip_start.upto(t_ip_end) do |ip|
                      ip = IPAddr.new(ip, Socket::AF_INET)
                      @proxy_pool.logger.info("start scan #{ip}.thread id[#{t_idx}]")
                      find_proxy(ip.to_s, ports)
                      @proxy_pool.logger.info("end scan #{ip}.thread id[#{t_idx}]")
                    end
                  end
      end

      threads.each { |t| t.join}
    end

    def find_proxy(ip, ports)
      proxys = ports.map { |port| Proxy.new(:ip => ip, :port => port)}

      result = proxy_pool.checker(proxys)
      if result.size > 0
        result.each { |proxy| puts proxy }

        @proxy_pool.proxys += result
        @proxy_pool.save_proxy
      end
    end

    # pattern like 192.168.0.1/24
    def parser_ips(ips)
      unless ips =~ /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\/24/
        raise VoyagerError.new("input ip pattern is invaild.[#{ips}]")
      end

      begin
        return IPAddr.new(ips)
      rescue => e
        raise VoyagerError.new("ip pattern is not correct. eg: '192.168.0.1/24'")
      end
    end

    def port_list(ports)
      arr = ports.split(',').collect {|p| p.to_i}

      raise VoyagerError.new("ports input error.") if arr.size <= 0
      arr
    end
  end
end