# encoding : utf-8

module HttpProxyPool
  class Proxy
    attr_accessor :ip,
                  :port,
                  :username,
                  :password,
                  :proxy_level,
                  :proxy_type,
                  :speed,
                  :added_time,
                  :last_access_time,
                  :nation,
                  :province,
                  :src_from,
                  :try_times

    def initialize(args = {})
      @ip         = args[:ip]
      @port       = args[:port]
      @username   = args[:username] || ''
      @password   = args[:password] || ''
      @proxy_type = args[:proxy_type]
      @proxy_level= args[:proxy_level]
      @speed      = args[:speed]
      @added_time = args[:added_time]
      @last_access= args[:last_access]
      @nation     = args[:nation]
      @province   = args[:province]
      @src_from   = args[:src_from]
      @try_times  = args[:try_times] || 0
    end

    def to_arr
      [@ip, @port, @proxy_type, @proxy_level, @nation, @province]
    end

    def to_s
      "#{@ip}\t#{@port}"
    end
  end
end