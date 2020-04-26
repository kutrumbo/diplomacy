module OrderService
  # output is of form { current_position: { order_type: [order_details]} }
  #   where order_details is a single area for move orders and an array
  #   of [from_area, to_area] for support and convoy orders
  def self.valid_orders(positions)
    valid_orders = {}
    positions.each do |position|
      order_map = {}
      order_map['hold'] = true
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
    possible_paths(current_position, other_positions).map(&:last).uniq
  end

  def self.valid_support_orders(current_position, other_positions)
    supportable_destinations = support_destinations(current_position)
    other_positions.reduce([]) do |orders, position|
      orders << [position.area, position.area] if supportable_destinations.include?(position.area)
      valid_move_orders(position, other_positions.without(current_position)).filter do |area|
        supportable_destinations.include?(area)
      end.each do |target_area|
        orders << [position.area, target_area]
      end
      orders
    end
  end

  def self.valid_convoy_orders(current_position, other_positions)
    raise 'Only fleets may convoy' unless current_position.fleet?
    if current_position.area.land?
      []
    else
      # TODO
    end
  end

  private

  def self.support_destinations(position)
    if position.fleet?
      fleet_possible_paths(position).map(&:last)
    else
      position.neighboring_areas.army_accessible
    end
  end

  def self.possible_paths(position, other_positions)
    if position.fleet?
      fleet_possible_paths(position)
    else
      army_possible_paths(position, other_positions, [position.area])
    end
  end

  def self.fleet_possible_paths(position)
    position.neighboring_areas.fleet_accessible.reject do |area|
      position.coast.present? && !area.neighboring_coasts.include?(position.coast)
    end.map do |destination|
      [position.area, destination]
    end
  end

  # Returns paths that an army can move to directly or via convoy
  def self.army_possible_paths(current_position, remaining_positions, current_path, paths=[])
    current_position.neighboring_areas.each do |neighboring_area|
      paths << [*current_path, neighboring_area] if neighboring_area.land?

      if fleet_position = remaining_positions.find { |p| p.fleet? && p.area == neighboring_area }
        army_possible_paths(
          fleet_position,
          remaining_positions.without(current_position, fleet_position),
          [*current_path, neighboring_area],
          paths,
        )
      end
    end
    paths
  end
end
