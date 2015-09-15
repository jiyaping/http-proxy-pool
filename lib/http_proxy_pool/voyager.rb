#encoding : utf-8

require 'IPAddr'

module HttpProxyPool
  class Voyager
    PORTS          = '8080,8081,80,9020,1080'
    IPV4_LEN       = 32

    def start(ips, thread_num, pool, ports = PORTS)
      ports_arr = post_list(ports)
      ip        = parser_ips(ips)
      proxy_pool= pool

      dispatcher(ip, thread_num, proxy_pool)
    end

    def dispatcher(ip, thread_num, pool)
      ip_start = ip.to_range.begin.to_i
      ip_end   = ip.to_range.end.to_i

      task_count = (ip_end - ip_start) / thread_num
      threads  = []
      thread_num.times do |t_idx|
        threads<< Thread.new do
                    t_ip_start = t_idx * task_count + ip_start
                    t_ip_end   = (t_idx + 1) * task_count

                    t_ip_end   = ip_end if t_ip_end > ip_end

                    t_ip_start.upto(t_ip_end) do |ip|
                      pool.logger.info("start scan #{ip}.")
                      find_proxy(ip, ports, pool)
                      pool.logger.info("end scan #{ip}.")
                    end
                  end
      end

      threads.each { |t| t.join}
    end

    def find_proxy(ip, ports, pool)
      proxys = ports.map { |port| Proxy.new(:ip => ip, :port => port)}

      pool.proxys += pool.checker(proxys)
    end

    # pattern like 192.168*
    def parser_ips(ips)
      ips_arr =  ips.split(".").collect do |item|
                  if item =~ /^\d{1,3}\*?$/
                    raise VoyagerError.new("ip range is invaild![#{ips}]")
                  end

                  item = item.tr('*','')
                end
      mask_len = IPV4_LEN - ips_arr.join.size
      # fill to four field
      while ips_arr < (IPV4_LEN / 8)
        ips_arr << '0'
      end

      begin
        return IPAddr.new("#{(ips_arr.join('.')}/#{mask_len}")
      rescue => e
        raise VoyagerError.new("ip pattern is not correct. eg: '192.168.*'")
      end
    end

    def post_list(ports)
      arr = ports.split(',').collect {|p| p.to_i}

      raise VoyagerError.new("ports input error.") if arr.size <= 0
      arr
    end
  end
end