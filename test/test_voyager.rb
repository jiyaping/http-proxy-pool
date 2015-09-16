# encoding : utf-8

gem "minitest"
require 'minitest/autorun'
require 'http_proxy_pool'

class VoyagerTest < Minitest::Test
  def setup
    @proxy_pool = HttpProxyPool::ProxyPool.new(
                    :data_path=> File.join(HttpProxyPool.home, 'ips-test.yaml'),
                    :script   => Dir["#{HttpProxyPool.home}/script/*.site"],
                    :logger   => HttpProxyPool.logger
                  )
    @voyager = HttpProxyPool::Voyager.new(@proxy_pool)
  end

  def test_ports_list
    str    = "8080,8091,"
    expect = [8080, 8091]

    assert_equal expect, @voyager.port_list(str)
  end

  def test_parse_ip
    ip_str  = "192.168.0.1/24"
    ip_start= "192.168.0.0"
    ip_end  = "192.168.0.255"

    assert_equal ip_start, @voyager.parser_ips(ip_str).to_range.begin.to_s
    assert_equal ip_end, @voyager.parser_ips(ip_str).to_range.end.to_s
  end
end