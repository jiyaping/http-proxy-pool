gem "minitest"
require 'minitest/autorun'
require 'http_proxy_pool'

class BaseSiteTest < Minitest::Test
  def setup
    @agent = Mechanize.new
  end

  def test_initialize_no_args
    assert HttpProxyPool::BaseSite.new
  end

  def test_initialize_with_agent
    assert HttpProxyPool::BaseSite.new(:agent => @agent)
  end

  def test_sitename
    basesite = HttpProxyPool::BaseSite.new(:agent => @agent,
                                            :url => 'http://baidu.com/test')

    assert_equal 'baidu.com', basesite.sitename
  end
end
