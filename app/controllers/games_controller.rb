class GamesController < ApplicationController
  before_action :require_authentication

  def index
    @games = current_user.games
  end

  def show
    @game = current_user.games.find(params[:id])
    @turn = @game.turns.order(:number).last
  end
end
