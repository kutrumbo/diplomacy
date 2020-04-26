module OrderService
  # output is of form { [position]: { [order_type]: [order_details]} }
  #   where order_details is a single area for move orders and an array
  #   of [from_area, to_area] for support and convoy orders
  def self.valid_orders(user_game)
    all_positions = user_game.game.positions

    user_game.positions.with_unit.reduce({}) do |order_map, position|
      position_order_map = {}
      position_order_map['move'] = valid_move_orders(position, all_positions.without(position))
      position_order_map['support'] = valid_support_orders(position, all_positions.without(position))
      if position.fleet?
        position_order_map['convoy'] = valid_convoy_orders(position, all_positions.without(position))
      end
      order_map[position] = position_order_map
      order_map
    end
  end

  def self.valid_move_orders(current_position, other_positions)
    possible_paths(current_position, other_positions).map(&:last).uniq
  end

  def self.valid_support_orders(current_position, other_positions)
    supportable_destinations = support_destinations(current_position)
    other_positions.reduce([]) do |orders, position|
      # allow supporting a position to hold if it is an accessible area
      orders << [position.area, position.area] if supportable_destinations.include?(position.area)

      # allow supporting any move from another position to an accessible area
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
    return [] if current_position.area.land?

    coastal_army_positions = other_positions.select do |position|
      position.army? && position.area.coastal?
    end

    # filter for all convoyed paths that go through the current position's area
    coastal_army_positions.map do |position|
      remaining_positions = other_positions.without(position).concat([current_position])
      possible_paths(position, remaining_positions).select do |path|
        path.include?(current_position.area)
      end.map do |path|
        # only want start and destination areas
        [path.first, path.last]
      end.uniq
    end.flatten(1)
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
    end.reject do |path|
      path.first == path.last
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

      convoy_position = remaining_positions.find do |position|
        position.fleet? && position.area.sea? && position.area == neighboring_area
      end

      if convoy_position.present?
        army_possible_paths(
          convoy_position,
          remaining_positions.without(current_position, convoy_position),
          [*current_path, neighboring_area],
          paths,
        )
      end
    end
    paths
  end
end
