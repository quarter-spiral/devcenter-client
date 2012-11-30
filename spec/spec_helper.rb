ENV['RACK_ENV'] ||= 'test'

Bundler.require

require 'minitest/autorun'

require 'graph-backend'
require 'datastore-backend'
require 'auth-backend'
require 'devcenter-backend'
require 'rack/client'

GRAPH_BACKEND = Graph::Backend::API.new
module Auth::Backend
  class Connection
    alias raw_initialize initialize
    def initialize(*args)
      result = raw_initialize(*args)

      graph_adapter = Service::Client::Adapter::Faraday.new(adapter: [:rack, GRAPH_BACKEND])
      @graph.client.raw.adapter = graph_adapter

      result
    end
  end
end

DATASTORE_BACKEND = Datastore::Backend::API.new
module Devcenter::Backend
  class Connection
    alias raw_initialize initialize
    def initialize(*args)
      result = raw_initialize(*args)

      datatstore_adapter = Service::Client::Adapter::Faraday.new(adapter: [:rack, DATASTORE_BACKEND])
      @datastore.client.raw.adapter = datatstore_adapter

      graph_adapter = Service::Client::Adapter::Faraday.new(adapter: [:rack, GRAPH_BACKEND])
      @graph.client.raw.adapter = graph_adapter

      result
    end
  end
end

require 'devcenter-client'

def wipe_graph!
  connection = Graph::Backend::Connection.create.neo4j
  (connection.find_node_auto_index('uuid:*') || []).each do |node|
    connection.delete_node!(node)
  end
end
wipe_graph!