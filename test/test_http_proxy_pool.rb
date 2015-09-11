gem "minitest"
require 'minitest/autorun'
require 'http_proxy_pool'

class HttpProxyPoolTest < Minitest::Test
  def test_home_is_not_null
    assert HttpProxyPool.home
  end

  def test_script_path
    assert File.join(HttpProxyPool.home, 'script'), HttpProxyPool.script_path
  end
end