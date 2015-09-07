#encoding : utf-8

module HttpProxyPool
  class Xicidaili1 < BaseSite
    def setup
      @url = 'http://www.xicidaili.com/nn/%s'
    end

    def run
      start_page  = 1
      end_page    = 2

      start_page.upto(end_page).each do |idx|
        @url = @url % idx

        page = @agent.get(@url).search("#ip_list").search("tr")
        page.each do |tr|
          yield node(tr)
        end
      end
    end

    def node(node)
      tds = node.search('td')
      fields = {}

      fields[:nation]     = tds[1].at('img')['alt']
      fields[:ip]         = tds[2].text
      fields[:port]       = tds[3].text
      fields[:province]   = tds[4].at('a').text
      fields[:proxy_level]= tds[5].text
      fields[:proxy_type] = tds[6].text
      fields[:speed]      = tds[7].at('div')["title"]
      fields[:added_time] = tds[9].at('img')['alt']
      fields[:src_from]   = sitename

      fields
    end
  end
end