#encoding : utf-8

module HttpProxyPool
  class Basetask
    attr_accessor :agent,
                  :url,
                  :logger,
                  :page_parser,
                  :next_page

    def sitetask(opts)
      raise ScriptError.new("script do not specify a url!") unless opts[:url]

      url   = opts[:url]
      agent = opts[:agent] || Mechanize.new
      logger= opts[:logger]|| HttpProxyPool.logger

      yield
    end

    def ips(lastpage = 1)
      page_counter = 0

      begin
        while(url = next_page.call)
          agent.get(url)
          page_counter += 1
          page_parser.call.each do |field|
            yield field
          end
          break if page_counter <= page_counter
        end
      rescue Mechanize::ResponseCodeError => e
        @logger.warn("#{agent.page.uri} is the last page. #{e.page}")
      rescue => e
        @logger.error("parser the page #{agent.page.uri} Error occurred. #{e.to_s}")
      end
    end

    def parser(&block)
      page_parser = block
    end

    def nextpage(&block)
      next_page = &block
    end

    def curr_page
      agent.page.uri
    end

    def sitename
      URI.parse(URI.encode(@url)).host
    end
  end
end