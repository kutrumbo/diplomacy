module OrderService
  # output is of form { current_position: { order_type: [[to, from?]]} }
  def self.valid_orders(positions)
    valid_orders = {}
    positions.each do |position|
      order_map = {}
      order_map['move'] = valid_move_orders(position, positions.without(position))
      order_map['support'] = valid_support_orders(position, positions.without(position))
      if position.fleet?
        order_map['convoy'] = valid_convoy_orders(position, positions.without(position))
      end
      valid_orders[position] = order_map
    end
    valid_orders
  end

  def self.valid_move_orders(current_position, other_positions)
    if current_position.fleet?
      current_position.neighboring_areas.fleet_accessible
    else
      army_accessible_destinations(current_position, other_positions).without(current_position.area)
    end
  end

  def self.valid_support_orders(current_position, other_positions)

  end

  def self.valid_convoy_orders(current_position, other_positions)
    if current_position.army? || current_position.area.land?
      return []
    end
  end

  private

  def self.army_accessible_destinations(current_position, other_positions)
    current_position.neighboring_areas.reduce([]) do |destinations, area|
      fleet_position = other_positions.find { |p| p.fleet? && p.area == area }
      new_destinations = if area.land?
        [area]
      elsif fleet_position
        remaining_positions = other_positions.without(current_position, fleet_position)
        army_accessible_destinations(fleet_position, remaining_positions)
      else
        []
      end

      destinations.concat(new_destinations).uniq
    end
  end
end
