#encoding : utf-8

module HttpProxyPool
  class BaseSite
    attr_accessor :agent,
                  :url,
                  :logger

    def initialize(args = {})
      @agent  = args[:agent] || Mechanize.new
      @url    = args[:url]
      @logger = args[:logger]
    end

    def sitename
      URI.parse(URI.encode(@url)).host
    end
  end
end