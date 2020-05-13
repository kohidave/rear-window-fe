require 'dynamoid'
require 'json'
require "securerandom"
require 'date'
require "active_support/all"
require_relative 'emojis'

Dynamoid.configure do |config|
    config.namespace = nil
end

class GameOverError < StandardError; end


class Game
    include Dynamoid::Document
    table name: :game, key: :game_id
    field :start_at, :datetime
    field :end_at, :datetime
end

class Player
    include Dynamoid::Document
    table name: :game_player, key: :game_id
    range :user_id, :string

    field :name, :string
    field :points, :integer, default: 0
    field :current_image, :string
    field :actual_emojis, :array, of: :string
    field :choice_emojis, :array, of: :string
    field :guessed_emojis, :array, of: :string
end

class GameService
    def create_game
        new_game = Game.new
        new_game.game_id = SecureRandom.hex(5)
        new_game.save
        return new_game
    end

    def game(game_id)
        Game.find(game_id)
    end

    def describe_game(game_id)
        current_game = Game.find(game_id)
        current_players = Player.find_all_by_composite_key(game_id)
        return {
            game: current_game,
            players: current_players
        }
    end

    def start_game(game_id, durration)
        game = Game.find(game_id)
        if game.start_at
            return game
        end
        game.start_at = DateTime.now
        game.end_at = (game.start_at.to_time + durration.minutes).to_datetime
        game.save
        return game
    end

    def join_game(game_id, name)
        game = Game.find(game_id)
        if game.start_at
            raise "game already started"
        end
        new_player = Player.new
        new_player.name = name
        new_player.game_id = game_id
        new_player.user_id =  SecureRandom.hex(5)
        new_player.save

        return new_player
    end

    def new_play(game_id, player, image, image_emojis, lazy)
        game = Game.find(game_id)
        if game.start_at == nil
            raise "game hasn't started yet"
        end

        if game.end_at && game.end_at.past?
            raise GameOverError
        end

        player = Player.where(game_id: game_id, user_id: player).first
        return player if lazy && player.current_image
        player.current_image = image
        player.actual_emojis = image_emojis
        player.choice_emojis = Emojify.RandomEmojis(10) | Set.new(image_emojis.to_a.sample(10))
        player.guessed_emojis = Set.new
        player.save

        return player
    end

    def new_guess(game_id, player, emoji_guess)
        game = Game.find(game_id)
        if game.start_at == nil
            raise "game hasn't started yet"
        end

        if game.end_at && game.end_at.past?
            raise GameOverError
        end

        player = Player.find_by_composite_key(game_id, player)
        if player.guessed_emojis.include? emoji_guess
            raise "already guessed"
        end
        player.guessed_emojis.push emoji_guess
        pont_diff = 0
        if player.actual_emojis.include? emoji_guess
            pont_diff = 100
        else
            pont_diff =  -50
        end
        player.points +=  pont_diff
        player.save

        return {player_points: player.points, point_diff: pont_diff}
    end

end
