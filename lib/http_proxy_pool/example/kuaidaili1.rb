#encoding : utf-8

module HttpProxyPool
  class Kuaidaili1 < BaseSite
    def initialize(args = {})
      super(args)
      @url = args[:url] || 'http://www.kuaidaili.com/free/inha/%s'
    end

    def run
      start_page  = 1
      end_page    = 10

      start_page.upto(end_page).each do |idx|
        url = url % idx

        page = @agent.get(url).search("tbody").search("tr")
        page.each do |tr|
          yield node(tr)
        end
      end
    end

    def node(node)
      tds = node.search('td')

      fields = {}

      fields[:ip]         = tds[0].text
      fields[:port]       = tds[1].text
      fields[:proxy_level]= tds[2].text
      fields[:proxy_type] = tds[3].text
      fields[:province]   = tds[4].at('a').text
      fields[:speed]      = tds[5].text
      fields[:added_time] = tds[6].text
      fields[:src_from]   = sitename

      fields
    end
  end
end