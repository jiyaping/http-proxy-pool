#encoding : utf-8

module HttpProxyPool
  class Basetask
    attr_accessor :agent,
                  :url,
                  :logger,
                  :page_parser,
                  :next_page

    def initialize(opts = {})
      agent  = opts[:agent]
      logger = opts[:logger]
      url    = opts[:url]
    end

    def sitetask(opts = {})
      raise ScriptError.new("script do not specify a url!") unless opts[:url]

      url   = opts[:url]
      agent = opts[:agent] || Mechanize.new

      yield

      puts page_parser.class
      puts next_page.class
    end

    def ips(lastest = true)
      page_counter = 0

      begin
        while(uri = next_page.call(agent))
          agent.get(uri)
          page_counter += 1
          instance_eval(page_parser).each do |field|
            yield field
          end
          break if (page_counter <= page_counter && lastest) 
        end
      rescue Mechanize::ResponseCodeError => e
        @logger.warn("#{agent.page.uri} is the last page. #{e.to_s}")
      rescue => e
        @logger.error("parser the page #{agent.page.uri} Error occurred. #{e.to_s}")
      end
    end

    def parser(&block)
      page_parser = block
    end

    def nextpage(&block)
      next_page = block
    end

    def curr_page
      agent.page.uri
    end

    def sitename
      URI.parse(URI.encode(@url)).host
    end
  end
end