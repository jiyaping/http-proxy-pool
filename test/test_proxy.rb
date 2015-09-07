gem "minitest"
require 'minitest/autorun'
require 'http_proxy_pool'

class ProxyTest < Minitest::Test
  def setup
    fields = {
              :ip => '127.0.0.1',
              :port => 8080,
              :username => 'jiyaping',
              :password => 'xxxxxx',
              :proxy_level => 'high',
              :proxy_type => 'http',
              :speed => '0.5',
              :added_time => DateTime.now,
              :last_access_time => DateTime.now,
              :nation => 'cn',
              :province => 'guangdong',
              :src_from => 'xxxxxx.com'
            }

    @proxy = HttpProxyPool::Proxy.new fields
  end

  def test_to_arr
    assert @proxy.to_arr
  end
end
