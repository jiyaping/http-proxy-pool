#encoding : utf-8

module HttpProxyPool
  class BaseError < StandardError; end
  class ScriptError < BaseError; end
  class TaskError < BaseError; end
  class QueryError < BaseError; end
end