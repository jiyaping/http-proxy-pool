gem "minitest"
require 'minitest/autorun'
require 'http_proxy_pool'

class ProxyPoolTest < Minitest::Test
  def setup
    data_path = File.join(HttpProxyPool.home, 'ips-test.yaml')
    script    = Dir["#{HttpProxyPool.home}/script/*.site"]
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
    #assert  @proxy_pool.crawling
  end

  def test_build_query_parameter
    except_str = "test.ip =~ '10.12.68.12' && test.nation == 'cn'"
    result     = @proxy_pool.build_query_parameter(prefix = 'test',
                        :ip => "=~ '10.12.68.12'", 
                        :nation => "== 'cn'"
                  )

    assert_equal except_str, result
  end

  def test_one_condtion_query
    args = {:ip => '=~ /11/'}

    result = @proxy_pool.query(args)

    assert result
  end

  def test_two_condition_query
    args = {:ip => '=~ /12/'}
    arr = []
    @proxy_pool.query(args) do |proxy|
      arr<< proxy
    end

    assert_equal @proxy_pool.query(args).size, arr.size
  end

  def test_query_key_filter
    keys = [:ip]
    result = @proxy_pool.query_key_filter(:ip=>'test', :invalid_key=> 'test')

    assert_equal keys, result.keys
  end

  def test_checher
    proxy = HttpProxyPool::Proxy.new(:ip => '127.0.0.1', :port => '12345')

    refute @proxy_pool.checker(proxy)
  end

  def test_batch
    proxys = []
    proxys << HttpProxyPool::Proxy.new(:ip => '127.0.0.1', :port => '12342')
    proxys << HttpProxyPool::Proxy.new(:ip => '127.0.0.1', :port => '12346')
    proxys << HttpProxyPool::Proxy.new(:ip => '127.0.0.1', :port => '12314')
    proxys << HttpProxyPool::Proxy.new(:ip => '127.0.0.1', :port => '12345')
    proxys << HttpProxyPool::Proxy.new(:ip => '127.0.0.1', :port => '12347')

    assert @proxy_pool.checker(proxys)
  end

  def test_all_ip
    result = @proxy_pool.checker(@proxy_pool.query(:ip=> "=~ /.*/"))

    assert result
  end
end