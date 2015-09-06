#encoding : utf-8

module HttpProxyPool
  class BaseSite
    attr_accessor :agent,
                  :url

    def initialize(args = {})
      @agent  = args[:agent] || Mechanize.new
      @url    = args[:url]
    end

    def sitename
      URI.new(URI.encode(@url)).host
    end
  end
end