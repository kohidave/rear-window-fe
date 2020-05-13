require 'logger'
require 'sinatra/base'
require "sinatra/json"
require 'haml'
require 'json'
require 'time'

require_relative 'image'
require_relative 'game'

$stdout.sync = true

class App < Sinatra::Base
  enable :static
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :root, File.join(File.dirname(__FILE__))
  set :port, 80
  set :show_exceptions, false
  set :raise_errors, false
  set :environment, :production

  error GameOverError do
    status 400
    "game over"
  end

  get '/hc' do
    'healthy'
  end

  get '/' do
    haml :new_game
  end

  # Creates a game
  post '/game' do
    gs = GameService.new
    json gs.create_game
  end

  # View an existing game.
  get '/game/:game_id' do
    game_id = params['game_id']
    gs = GameService.new
    @game_description = gs.describe_game(game_id)
    game = @game_description[:game]
    if game.end_at && game.end_at.past?
        haml :game_over
    else
        haml :game
    end
  end

  # Fetch the JSON status of a game.
  get '/game/:game_id/status' do
    game_id = params['game_id']
    gs = GameService.new
    json gs.game(game_id)
  end

  # Adds folks to a game
  post '/game/:game_id/member/:name' do
    game_id = params['game_id']
    name_id = params['name']
    gs = GameService.new
    json gs.join_game(game_id, name_id)
  end

  # Starts a game
  post '/game/:game_id/start' do
    game_id = params['game_id']
    gs = GameService.new
    json gs.start_game(game_id, 1)
  end

  # Create a new turn for a player
  post '/game/:game_id/turn/:player_id' do
    game_id = params['game_id']
    player_id = params['player_id']
    gs = GameService.new
    imgsrvc = ImageService.new
    image = imgsrvc.image
    player = gs.new_play(game_id, player_id, image.url, image.emojis, false)
    json image_url: player.current_image, emojis: player.choice_emojis
  end

  # Getches the turn for a given player
  get '/game/:game_id/turn/:player_id' do
    game_id = params['game_id']
    player_id = params['player_id']
    gs = GameService.new
    imgsrvc = ImageService.new
    image = imgsrvc.image
    @player = gs.new_play(game_id, player_id, image.url, image.emojis, true)
    haml :turn
  end

  post '/game/:game_id/turn/:player_id/guess' do
    body = JSON.parse(request.body.read)
    game_id = params['game_id']
    player_id = params['player_id']
    emoji_guess = body["emoji"]
    gs = GameService.new
    json gs.new_guess(game_id, player_id, emoji_guess)
  end

end
