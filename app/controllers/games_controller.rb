class GamesController < ApplicationController
  before_action :require_authentication

  def index
    @games = current_user.games
  end

  def show
    game_id = params[:id]
    @game = current_user.games.find(game_id)
    @turn = @game.turns.order(:number).last
    @positions = current_user.user_games.find_by(game_id: game_id).positions
  end
end
