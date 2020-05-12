class OrderResolutionService
  def initialize(turn)
    @orders = turn.orders
    @order_position_map = {}
    @attack_pressure_map = {}
  end

  def resolve_orders
    @orders.group_by do |o|
      raise "Order already resolved" if o.resolution.present?
      resolution_status = resolve(o).first
      Resolution.create!(order: o, status: resolution_status)
    end
  end

  def order_position_map(order)
    @order_position_map[order] ||= order.position
  end

  def attack_pressure_map(area, orders)
    orders_pressure = @attack_pressure_map[area] ||= {}
    order_ids = orders.map(&:id).sort
    if orders_pressure[order_ids].nil?
      orders_pressure[order_ids] = attacking_pressure(area, orders)
    end
    orders_pressure[order_ids]
  end

  def order_area(order)
    AreaService.area_map[order_position_map(order).area_id]
  end

  def resolve(order)
    case order.type
    when 'move'
      resolve_move(order, @orders)
    when 'hold'
      resolve_hold(order, @orders)
    when 'support'
      resolve_support(order, @orders)
    when 'convoy'
      resolve_convoy(order, @orders)
    when 'build_army', 'build_fleet', 'no_build', 'disband', 'keep'
      [:resolved]
    when 'retreat'
      resolve_retreat(order, @orders)
    else
      raise 'Invalid order type'
    end
  end

  def resolve_retreat(order, orders)
    if conflicting_order = orders.without(order).find { |o| o.to_id == order.to_id }
      [:failed, conflicting_order]
    else
      [:resolved]
    end
  end

  def resolve_move(order, orders)
    if requires_convoy?(AreaService.area_map[order.from_id], AreaService.area_map[order.to_id])
      convoying_orders = orders.select do |o|
        o.convoy? && o.from_id == order.from_id && o.to_id == order.to_id
      end
      return [:invalid] if convoying_orders.empty?

      # TODO: need to support multiple convoy routes
      convoys_disrupted = convoying_orders.any? do |o|
        resolve_hold(o, orders) != [:resolved]
      end
      return [:cancelled] if convoys_disrupted
    end

    attack_hash = attack_pressure_map(AreaService.area_map[order.to_id], orders)
    attack_succeeds = attack_hash.key?(order) && attack_hash[order].size + 1 > hold_support(AreaService.area_map[order.to_id], orders).size
    unless attack_succeeds && attack_hash.keys == [order]
      # if attack fails or if one of multiple successful attacks, determine if it holds its area
      hold_resolution = resolve_hold(order, orders)
      return [:bounced] if hold_resolution == [:resolved]
      if hold_resolution == [:broken]
        return attack_hash.size == 1 ? [:broken, attack_hash.keys.first] : [:bounced]
      end
      return hold_resolution
    end

    # bounce if target area contains a unit moving to the current location
    if orders.any? { |o| o.move? && o.to_id == order.from_id && o.from_id == order.to_id }
      return [:bounced]
    end

    # do not allow a power to dislodge its own unit
    if orders.any? { |o| !o.move? && order_position_map(o).area_id == order.to_id && o.power == order.power }
      return [:bounced]
    end
    [:resolved]
  end

  def resolve_hold(order, orders)
    attack_hash = attack_pressure_map(order_area(order), orders)
    return [:resolved] if attack_hash.empty?
    attack_strength = attack_hash.values.first.size + 1
    hold_strength = hold_support(order_area(order), orders).size
    if attack_strength > hold_strength
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
    return [:resolved] if order.hold?
    order.move? ? [:broken] : [:cut, attack_hash.keys.first]
  end

  def resolve_support(order, orders)
    corresponding_order = orders.find do |o|
      valid_move_hold = (o.move? || o.hold?) && order.from_id == o.from_id && order.to_id == o.to_id
      valid_support = (o.support? || o.convoy?) && o.position.area_id == order.from_id && o.position.area_id == order.to_id
      valid_move_hold || valid_support
    end
    return [:invalid] unless corresponding_order.present?
    attack_hash = attack_pressure_map(order_area(order), orders).reject do |o, _|
      # exclude any attacks from the target area to the current support
      o.move? && o.from_id == order.to_id && o.to_id == order_area(order).id
    end
    attack_hash.present? ? resolve_hold(order, orders) : [:resolved]
  end

  def resolve_convoy(order, orders)
    unless orders.any? { |o| o.move? && o.from_id == order.from_id && o.to_id == order.to_id }
      return [:invalid]
    end

    supporting_convoys = orders.without(order).select do |o|
      o.convoy? && o.from_id == order.from_id && o.to_id == order.to_id
    end
    convoys_disrupted = supporting_convoys.any? do |o|
      resolve_hold(o, orders) != [:resolved]
    end
    return [:cancelled] if convoys_disrupted

    resolve_hold(order, orders)
  end

  private

  def requires_convoy?(from, to)
    # TODO: does not handle convoying to adjacent coast
    !AreaService.neighboring_areas_map[from].include?(to)
  end

  def hold_support(area, orders)
    orders.select do |o|
      non_moving_position_at_area = order_position_map(o).area_id == area.id && !o.move?
      support_hold_order = o.support? && o.from_id == area.id && o.to_id == area.id && orders.any? do |i|
        # verify there is a non-moving unit at the area to support
        !i.move? && i.position.area_id == area.id
      end
      failed_move_order_at_area = if order_position_map(o).area_id == area.id && o.move?
        attack_hash = attack_pressure_map(AreaService.area_map[o.to_id], orders)
        attack_succeeds = attack_hash.key?(o) && attack_hash[o].size + 1 > hold_support(AreaService.area_map[o.to_id], orders.without(o)).size
        !attack_succeeds || attack_hash.keys != [o]
      end

      non_moving_position_at_area || support_hold_order || failed_move_order_at_area
    end
  end

  # returns hash of { attack_order: [supporting_orders] } excluding the less supported attacks
  def attacking_pressure(area, orders)
    orders.select do |o|
      o.move? && o.to_id == area.id
    end.reduce({}) do |attack_hash, o|
      support = attack_support(o, orders.without(o))
      prev_support_level = (attack_hash.values.first || []).size
      return Hash[o, support] if support.size > prev_support_level
      attack_hash[o] = support if support.size == prev_support_level
      attack_hash
    end
  end

  def attack_support(order, orders)
    orders.select do |o|
      order_supports_attack = o.support? && o.from_id == order.from_id && o.to_id == order.to_id
      order_not_cut = attack_pressure_map(order_area(o), orders).all? do |attack_order, _|
        attack_order.from_id == order.to_id
      end
      order_supports_attack && order_not_cut
    end
  end
end
