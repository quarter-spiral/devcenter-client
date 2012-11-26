require_relative './spec_helper'
require 'uuid'

API_APP = Devcenter::Backend::API.new
AUTH_APP = Auth::Backend::App.new(test: true)

module Auth
  class Client
    alias raw_initialize initialize
    def initialize(url, options = {})
      raw_initialize(url, options.merge(adapter: [:rack, AUTH_APP]))
    end
  end
end

require 'auth-backend/test_helpers'
auth_helpers = Auth::Backend::TestHelpers.new(AUTH_APP)
token = auth_helpers.get_token

app = auth_helpers.create_app!
app_token = auth_helpers.get_app_token(app[:id], app[:secret])

ENV['QS_OAUTH_CLIENT_ID'] = app[:id]
ENV['QS_OAUTH_CLIENT_SECRET'] = app[:secret]

describe Graph::Client do
  before do
    @client = Devcenter::Client.new('http://example.com')

    adapter = Service::Client::Adapter::Faraday.new(adapter: [:rack, API_APP])
    @client.client.raw.adapter = adapter

    @connection = Devcenter::Backend::Connection.create

    @developer = UUID.new.generate
    @connection.graph.add_role(@developer, app_token, 'developer')


    @game_options1 = {:name => "Test Game 1", :description => "Good game", :configuration => {'type' => 'html5', 'url' => 'http://example.com'},:developers => [@developer], :venues => {"spiral-galaxy" => {"enabled" => true}}}
    @game1 = Devcenter::Backend::Game.create(app_token, @game_options1)
    @game_options2 = {:name => "Test Game 2", :description => "Good game", :configuration => {'type' => 'html5', 'url' => 'http://example.com'},:developers => [@developer], :venues => {"spiral-galaxy" => {"enabled" => true}}}
    @game2 = Devcenter::Backend::Game.create(app_token, @game_options2)
    @game_options3 = {:name => "Test Game 3", :description => "Good game", :configuration => {'type' => 'html5', 'url' => 'http://example.com'},:developers => [@developer], :venues => {"spiral-galaxy" => {"enabled" => true}}}
    @game3 = Devcenter::Backend::Game.create(app_token, @game_options3)

  end

  it "can list public game info" do
    games = @client.list_games
    games.size.must_equal 3
    games.detect {|g| g['uuid'] == @game1.uuid}.wont_be_nil
    games.detect {|g| g['uuid'] == @game2.uuid}.wont_be_nil
    games.detect {|g| g['uuid'] == @game3.uuid}.wont_be_nil
  end

  it "can list public game info for some uuids" do
    games = @client.list_games([@game1.uuid, @game3.uuid])
    games.size.must_equal 2
    games.detect {|g| g['uuid'] == @game1.uuid}.wont_be_nil
    games.detect {|g| g['uuid'] == @game3.uuid}.wont_be_nil

    games = @client.list_games([@game2.uuid])
    games.size.must_equal 1
    games.detect {|g| g['uuid'] == @game2.uuid}.wont_be_nil
  end
end
