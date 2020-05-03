class OrdersController < ApplicationController
  def update
    orders = parse_orders
    if error = validate(orders)
      render json: error, status: :unprocessable_entity
    else
      Order.update(orders.keys, orders.values)
      render json: Order.find(orders.keys)
    end
  end

  def resolutions
    turn = current_user.games.find(params[:game_id]).turns.find(params[:turn_id])

    order_resolutions = OrderService.resolve_orders(turn)
    reorged_resolutions = order_resolutions.reduce([]) do |result, (resolution, orders)|
      orders.each do |order|
        # TODO: position look-up is an N+1 that we could avoid with a pre-fetch
        result << [order, resolution, order.position]
      end
      result
    end
    render json: reorged_resolutions
  end

  private

  def parse_orders
    @user_game = current_user.user_games.find_by_game_id(params[:game_id])
    @turn = @user_game.game.current_turn
    permitted_orders = @user_game.orders.where(turn: @turn).pluck(:id).reduce({}) do |acc, id|
      acc.merge(id.to_s.to_sym => [:type, :from_id, :from_coast_id, :to_id, :to_coast_id, :position_id, :confirmed])
    end
    params.require(:orders).permit(permitted_orders)
  end

  def validate(orders)
    valid_orders = OrderService.valid_orders(@user_game, @user_game.game.current_turn)
    if @turn.build?
      build_validations = validate_build_orders(orders)
      return build_validations if build_validations.present?
    end
    validations = orders.to_h.reduce({}) do |validation_map, (order_id, order)|
      permissible_orders = valid_orders[order[:position_id]][order[:type]]
      unless permissible_orders.include?([[order[:from_id], order[:from_coast_id]], [order[:to_id], order[:to_coast_id]]])
        validation_map[order_id] = true
      end
      validation_map
    end
    validations.present? && {
      message: 'Invalid order instructions',
      validations: validations,
    }
  end

  def validate_build_orders(orders)
    builds_available = PositionService.calculate_builds_available(@user_game, @turn)
    if builds_available > 0
      requested_builds = orders.to_h.reject { |order_id, order| order[:type] == 'no_build' }
      if requested_builds.size != builds_available
        return {
          message: "Invalid order instructions: must request exactly #{builds_available} #{'build'.pluralize(builds_available)}",
          validations: orders.to_h,
        }
      end
    else
      requested_disbands = orders.to_h.select { |order_id, order| order[:type] == 'disband' }
      if requested_disbands.size != builds_available.abs
        return {
          message: "Invalid order instructions: must request exactly #{builds_available.abs} #{'disband'.pluralize(builds_available.abs)}",
          validations: orders.to_h,
        }
      end
    end
  end
end
