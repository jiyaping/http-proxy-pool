gem "minitest"
require 'minitest/autorun'
require 'http_proxy_pool'

class ProxyPoolTest < Minitest::Test
  def setup
    data_path = File.join(HttpProxyPool.home, 'ips-test.yaml')
    script    = HttpProxyPool.execute_script
    logger    = HttpProxyPool.logger

    @proxy_pool = HttpProxyPool::ProxyPool.new(
                    :data_path=> data_path,
                    :script   => script,
                    :logger   => logger
                  )
  end

  def test_get_agent_alias
    assert @proxy_pool.get_agent_alias
  end

  def test_crawling
    assert  @proxy_pool.crawling
  end
end
