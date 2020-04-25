module OrderService
  # output is of form { current_position: { order_type: [[to, from?]]} }
  def self.valid_orders(positions)
    valid_orders = {}
    positions.each do |position|
      order_map = {}
      order_map['move'] = valid_move_orders(position)
      order_map['support'] = valid_support_orders(position, positions.without(position))
      if position.fleet?
        order_map['convoy'] = valid_convoy_orders(position, positions.without(position))
      end
      valid_orders[position] = order_map
    end
    valid_orders
  end

  private

  def self.valid_move_orders(position)
    if position.fleet?
      position.area.neighbors
    else

    end
  end

  def self.valid_support_orders(position, other_positions)
    if position.fleet?

    else

    end
  end

  def self.valid_convoy_orders(position, other_positions)
    raise 'Only fleets can convoy' unless position.fleet?

  end
end
