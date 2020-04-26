module OrderService
  # output is of form { [position_id]: { [order_type]: [from_id, to_id]} }
  def self.valid_orders(user_game)
    all_unit_positions = user_game.game.positions.with_unit

    user_game.positions.with_unit.reduce({}) do |order_map, position|
      position_order_map = {}
      position_order_map['hold'] = [nil, nil]
      moves = valid_move_orders(position, all_unit_positions.without(position))
      position_order_map['move'] = moves if moves.present?
      supports = valid_support_orders(position, all_unit_positions.without(position))
      position_order_map['support'] = supports if supports.present?
      if position.fleet?
        convoys = valid_convoy_orders(position, all_unit_positions.without(position))
        position_order_map['convoy'] = convoys if convoys.present?
      end
      order_map[position.id] = position_order_map
      order_map
    end
  end

  def self.valid_move_orders(current_position, other_unit_positions)
    possible_paths(current_position, other_unit_positions).map { |path| [nil, path.last.id] }.uniq
  end

  def self.valid_support_orders(current_position, other_unit_positions)
    support_areas = supportable_areas(current_position)
    other_unit_positions.reduce([]) do |orders, position|
      # allow supporting a position to hold if it is an accessible area
      orders << [position.area.id, position.area.id] if support_areas.include?(position.area)

      # allow supporting any move from another position to an accessible area
      valid_move_orders(position, other_unit_positions.without(position, current_position)).filter do |details|
        support_areas.map(&:id).include?(details.last)
      end.each do |details|
        orders << [position.area.id, details.last]
      end
      orders
    end
  end

  def self.valid_convoy_orders(current_position, other_unit_positions)
    raise 'Only fleets may convoy' unless current_position.fleet?
    return [] if current_position.area.land?

    coastal_army_positions = other_unit_positions.select do |position|
      position.army? && position.area.coastal?
    end

    # filter for all convoyed paths that go through the current position's area
    coastal_army_positions.map do |position|
      remaining_positions = other_unit_positions.without(position).concat([current_position])
      possible_paths(position, remaining_positions).select do |path|
        path.include?(current_position.area)
      end.map do |path|
        # only want start and destination areas
        [path.first.id, path.last.id]
      end.uniq
    end.flatten(1)
  end

  private

  def self.supportable_areas(position)
    if position.fleet?
      fleet_possible_paths(position).map(&:last)
    else
      position.neighboring_areas.army_accessible
    end
  end

  def self.possible_paths(position, other_unit_positions)
    if position.fleet?
      fleet_possible_paths(position)
    else
      army_possible_paths(position, other_unit_positions, [position.area])
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
