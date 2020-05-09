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
    @positions = @turn.positions.index_by(&:id)
    @positions_by_area = @turn.positions.includes(:area).group_by(&:area)
    @orders = @user_game.orders.where(turn: @turn).index_by(&:id)
    @valid_orders = OrderService.valid_orders(@user_game, @turn)
    @areas = AreaService.area_map
    @coasts = Coast.all.index_by(&:id)
    @user_games = @game.user_games.index_by(&:id)
  end

  def map
  end
end
