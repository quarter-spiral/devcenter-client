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
