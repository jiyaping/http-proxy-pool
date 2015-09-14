# http-proxy-pool 

在爬取网页数据、批量投票，点赞等日常中，经常需要更换ip信息，需要大量代理。http-proxy-pool可用于收集网络上免费代理，供其它脚本程序使用。http-proxy-pool可以通过自定义爬取脚本来收集网络代理信息。

## 安装

`gem install http-proxy-pool`


## 使用

### 1.命令行

* 初始化资源  
`proxypool crawl`

* 查看当前已收集状态  
`proxypool status`

* 随机获取一个可用代理，默认强制检查代理是否可用  
`proxypool get`

更多参数，参看`proxypool help`

### 2.在脚本中引用

    require 'http-proxy-pool'  

    pool = HttpProxyPool::ProxyPool.new  
    pool.query(:ip => "=~ /^111/", :proxy_type => "== 'HTTP'") do |proxy|
      # do what you want ...
    end

query查询出proxy资源不会强制，校验是否可用。可用checker通过来校验:

    pool.checker(proxy)

## 定义爬取脚本
http-proxy-pool默认脚本会安装到**[USER\_PATH]/http\_proxy\_pool/script**中，可以自己修改已有脚本，或者在此目录添加新脚本，目前自带以下网站（站点信息源自搜索引擎）爬取脚本:  

* [ip.izmoney.com](http://ip.izmoney.com)
* [kuaidaili.com](http://www.kuaidaili.com)
* [proxy360.cn](http://www.proxy360.cn)
* [goubanjia.com](http://proxy.goubanjia.com)

### 一个样例：
	
	# 开始抓取地址
    sitetask("start_page_url") do
      nextpage do
        # nextpage 最终返回下一页URL
        # 此部分需判断是否需要是否是最后页
        # 如果未定义nextpage部分，程序默认只会爬去第一页
      end

      parser do
        # 此部分，最终返回一个Proxy实例的数组
        # 此block中，可以通过解析当前Mechanize页面，通过dom数据生成多个Proxy
      end
    end

### 创建Proxy:

    HttpProxyPool::Proxy.new {
      :ip => '127.0.0.1', 				# IP地址
      :port => 8080,					# 端口
      :username => 'jiyaping',			# 认证用户名
      :password => 'xxxxxx',			# 认证密码
      :proxy_level => 'high',			# 代理等级（匿名、透明代理）
      :proxy_type => 'http',			# 代理类型（HTTP、HTTPS、SOCKS）
      :speed => '0.5',					# 代理速度
      :added_time => DateTime.now,		# 添加时间
      :last_access_time => DateTime.now,# 上次使用时间
      :nation => 'cn',					# 国家
      :province => 'guangdong',			# 省份/州
      :src_from => 'xxxxxx.com'			# 获取来源
    }

## 最后

就酱紫 ...