#encoding : utf-8

module HttpProxyPool
  class Xicidaili2 < Xicidaili1
    def initialize(args = {})
      super(args)
      @url = args[:url] || 'http://www.xicidaili.com/nt/%s'
    end
  end
end