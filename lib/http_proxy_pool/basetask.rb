#encoding : utf-8

module HttpProxyPool
  class Basetask
    attr_accessor :agent,
                  :url,
                  :logger,
                  :page_parser,
                  :next_page

    def initialize(opts = {})
      @agent  = opts[:agent]
      @logger = opts[:logger]
      @url    = opts[:url]
    end

    def sitetask(url, opts = {})
      raise ScriptError.new("script do not specify a url!") unless url

      @url      = url
      @agent    = opts[:agent] || Mechanize.new
      @logger   ||= opts[:logger]

      #for debug
      #@agent.set_proxy '127.0.0.1', 8888

      yield
    end

    def ips(lastest = true)
      uri = @url

      loop do
        @logger.info("start crawling page [#{uri}] ...")
        @agent.get(uri)
        # get all page need sleep a random time
        rand_sleep unless lastest

        begin
          instance_eval(&page_parser).each do |field|
            yield field
          end  
        rescue Exception => e
          @logger.error("parsing page error[#{uri}]. #{e.to_s}")
          break
        end

        begin
          break unless @next_page
          uri = instance_eval(&next_page)
          break unless uri
        rescue => e
          @logger.error("error occoured when get next page[#{uri}]. #{e.to_s}")
          break
        end

        break if lastest
      end
    end

    def parser(&block)
      @page_parser = block if block_given?
    end

    def nextpage(&block)
      @next_page = block if block_given?
    end

    def curr_page
      @agent.page.uri
    end

    def sitename
      URI.parse(URI.encode(@url)).host
    end

    def rand_sleep(max_tick = 2)
      sleep rand(max_tick)
    end
  end
end