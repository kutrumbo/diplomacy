class OrdersController < ApplicationController
  def update
    orders = parse_orders
    if validations = validate(orders)
      error = {
        message: 'Invalid order instructions',
        validations: validations,
      }
      render json: error, status: :unprocessable_entity
    else
      Order.update(orders.keys, orders.values)
      render json: Order.find(orders.keys)
    end
  end

  private

  def parse_orders
    @user_game = current_user.user_games.find_by_game_id(params[:game_id])
    turn = @user_game.game.current_turn
    permitted_orders = @user_game.orders.where(turn: turn).pluck(:id).reduce({}) do |acc, id|
      acc.merge(id.to_s.to_sym => [:type, :from_id, :to_id, :position_id, :confirmed])
    end
    params.require(:orders).permit(permitted_orders)
  end

  def validate(orders)
    valid_orders = OrderService.valid_orders(@user_game, @user_game.game.current_turn)
    validations = orders.to_h.reduce({}) do |validation_map, (order_id, order)|
      permissible_orders = valid_orders[order[:position_id]][order[:type]]
      unless permissible_orders.include?([order[:from_id], order[:to_id]])
        validation_map[order_id] = true
      end
      validation_map
    end
    validations.present? && validations
  end
end
