# Devcenter::Client

Client to the devcenter-backend.

## Usage

### Create a client
```ruby
# connect to local
client = Devcenter::Client.new('http://devcenter-backend.dev')
```

### Games

#### List all games
```ruby
client.list_games
```

#### Get public data of some games

```ruby
client.list_games([game_uuid1, game_uuid2])
```

#### Get platform data of a game

```ruby
game = client.get_game(token, uuid) # => {'name' => 'Test Game', 'configuration' => {}, …}
```