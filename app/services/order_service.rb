module OrderService
  # output is of form { [position_id]: { [order_type]: [from_id, to_id]} }
  def self.valid_orders(user_game)
    all_unit_positions = user_game.game.positions.with_unit

    user_game.positions.with_unit.reduce({}) do |order_map, position|
      position_order_map = {}
      position_order_map['hold'] = [[position.area_id, position.area_id]]
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
    possible_paths(current_position, other_unit_positions).map do |path|
      [current_position.area_id, path.last.id]
    end.uniq
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

  def self.resolve(order)
    case order.type
    when 'move'
      resolve_move(order, order.turn.orders)
    when 'hold'
      resolve_hold(order, order.turn.orders)
    when 'support'
      resolve_support(order, order.turn.orders)
    when 'convoy'
      resolve_convoy(order, order.turn.orders)
    when 'build'
      [:not_implemented] # TODO
    when 'retreat'
      [:not_implemented] # TODO
    else
      raise 'Invalid order type'
    end
  end

  def self.resolve_move(order, orders)
    if requires_convoy?(order.from, order.to)
      convoying_orders = orders.select do |o|
        o.convoy? && o.from == order.from && o.to == order.to
      end
      return [:invalid] if convoying_orders.empty?

      # TODO: need to support multiple convoy routes
      convoys_disrupted = convoying_orders.any? do |o|
        resolve_hold(o, orders) != [:resolved]
      end
      return [:cancelled] if convoys_disrupted
    end

    attack_hash = attacking_pressure(order.to, orders)
    attack_succeeds = attack_hash.key?(order) && (attack_hash[order].size + 1 > hold_support(order.to, orders).size)
    # bounce if not part of successful attack or multiple attacks have enough strength
    unless attack_succeeds && attack_hash.keys == [order]
      hold_resolution = resolve_hold(order, orders)
      return hold_resolution == [:resolved] ? [:bounced] : hold_resolution
    end

    # bounce if target area contains a unit moving to the current location
    if orders.any? { |o| o.move? && o.to == order.from && o.from == order.to }
      return [:bounced]
    end

    # do not allow self-dislodgement
    if orders.any? { |o| !o.move? && o.position.area == order.to && o.power == order.power }
      return [:bounced]
    end
    [:resolved]
  end

  def self.resolve_hold(order, orders)
    attack_hash = attacking_pressure(order.position.area, orders)
    return [:resolved] if attack_hash.empty?

    attack_strength = attack_hash.values.first.size + 1
    if attack_strength > hold_support(order.position.area, orders).size
      # if multiple attackers, attacks bounce and position holds
      if attack_hash.size == 1
        if attack_hash.keys.first.power == order.power
          # do not allow self-dislodgement
          return [:resolved]
        else
          return [:dislodged, attack_hash.keys.first]
        end
      end
    end
    # TODO: convoy attack can not cut support to a fleet supporting another convoying fleet
    order.hold? ? [:resolved] : [:cut, attack_hash.keys.first]
  end

  def self.resolve_support(order, orders)
    corresponding_order = orders.find do |o|
      (o.move? || o.hold?) && order.from == o.from && order.to == o.to
    end
    return [:invalid] unless corresponding_order.present?
    attack_hash = attacking_pressure(order.position.area, orders).reject do |o, _|
      # exclude any attacks from the target area to the current support
      o.move? && o.from == order.to && o.to == order.position.area
    end
    attack_hash.present? ? resolve_hold(order, orders) : [:resolved]
  end

  def self.resolve_convoy(order, orders)
    unless orders.any? { |o| o.move? && o.from == order.from && o.to == order.to }
      return [:invalid]
    end

    supporting_convoys = orders.without(order).select do |o|
      o.convoy? && o.from == order.from && o.to == order.to
    end
    convoys_disrupted = supporting_convoys.any? do |o|
      resolve_hold(o, orders) != [:resolved]
    end
    return [:cancelled] if convoys_disrupted

    resolve_hold(order, orders)
  end

  private

  def self.requires_convoy?(from, to)
    # TODO: does not handle convoying to adjacent coast
    !from.neighboring_areas.include?(to)
  end

  def self.hold_support(area, orders)
    orders.select do |o|
      order_originates_at_position = o.position.area == area && !o.move?
      order_supports_area = o.support? && o.from == area && o.to == area && orders.any? { |i| !i.move? && i.position.area == area }

      order_originates_at_position || order_supports_area
    end
  end

  # returns hash of { attack_order: [supporting_orders] } excluding the less supported attacks
  def self.attacking_pressure(area, orders)
    orders.select do |o|
      o.move? && o.to == area
    end.reduce({}) do |attack_hash, o|
      support = attack_support(o, orders.without(o))
      prev_support_level = (attack_hash.values.first || []).size
      return Hash[o, support] if support.size > prev_support_level
      attack_hash[o] = support if support.size == prev_support_level
      attack_hash
    end
  end

  def self.attack_support(order, orders)
    orders.select do |o|
      order_supports_attack = o.support? && o.from == order.from && o.to == order.to
      order_not_cut = attacking_pressure(o.position.area, orders).all? do |attack_order, _|
        attack_order.from == order.to
      end
      order_supports_attack && order_not_cut
    end
  end

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
