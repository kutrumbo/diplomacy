class OrdersController < ApplicationController
  def update
    orders = parse_orders
    orders.each do |order_id, order|
      puts order
    end
    ActiveRecord::Base.transaction do
      Order.update(orders.keys, orders.values)
      @user_game.update_attribute(:state, 'confirmed')
    end
    render json: Order.find(orders.keys)
  end

  private

  def parse_orders
    @user_game = current_user.user_games.find_by_game_id(params[:game_id])
    turn = @user_game.game.current_turn
    permitted_orders = @user_game.orders.where(turn: turn).pluck(:id).reduce({}) do |acc, id|
      acc.merge(id.to_s.to_sym => [:type, :from_id, :to_id])
    end
    params.require(:orders).permit(permitted_orders)
  end
end
