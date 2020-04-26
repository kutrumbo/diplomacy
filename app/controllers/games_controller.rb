class GamesController < ApplicationController
  before_action :require_authentication

  def index
    @games = current_user.games
  end

  def show
    game_id = params[:id]
    @user_game = current_user.user_games.find_by(game_id: game_id)
    @game = current_user.games.find(game_id)
    @turn = @game.current_turn
    @positions = @user_game.positions.index_by(&:id)
    @orders = @user_game.orders.where(turn: @turn).includes(:position)
    @valid_orders = OrderService.valid_orders(@user_game)
    @areas = Area.all.index_by(&:id)
  end
end
