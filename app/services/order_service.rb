module OrderService
  # output is of form { [position_id]: { [order_type]: [from_id, to_id]} }
  def self.valid_orders(user_game, turn)
    all_unit_positions = user_game.game.positions.with_unit.turn(turn)

    if turn.attack?
      valid_attack_orders(user_game, all_unit_positions, turn)
    elsif turn.retreat?
      valid_retreat_orders(user_game, all_unit_positions, turn)
    elsif turn.build?
      valid_build_orders(user_game, all_unit_positions, turn)
    end
  end

  def self.valid_attack_orders(user_game, all_unit_positions, turn)
    user_game.positions.with_unit.includes_areas.turn(turn).reduce({}) do |order_map, position|
      position_order_map = {}
      position_order_map['hold'] = [[[position.area_id, position.coast_id], [position.area_id, position.coast_id]]]
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

  def self.valid_retreat_orders(user_game, all_unit_positions, turn)
    previous_turn_order_resolutions = turn.previous_turn.orders.group_by { |o| o.resolution.status }
    user_game.positions.retreating.turn(turn).reduce({}) do |order_map, position|
      position_order_map = {}
      position_order_map['disband'] = [[[position.area_id, position.coast_id], [position.area_id, position.coast_id]]]
      retreat_areas = if position.army?
        AreaService.neighboring_areas_map[AreaService.area_map[position.area_id]].select { |a| a.land? }
      else
        PathService.fleet_accessible(AreaService.area_map[position.area_id])
      end.reject do |area|
        # cannot retreat to area where there is another unit, where there was a stand-off
        # the previous turn, or where the attacking order that dislodged the unit came from
        contains_unit = all_unit_positions.map(&:area).include?(area)
        stand_off_last_turn = (previous_turn_order_resolutions['bounced'] || []).any? do |order|
          order.to == area
        end
        dislodger_source = (previous_turn_order_resolutions['resolved'] || []).find do |order|
          order.move? && order.to == position.area
        end
        contains_unit || stand_off_last_turn || dislodger_source&.from == area
      end
      if retreat_areas.present?
        position_order_map['retreat'] = []
        retreat_areas.map do |area|
          if area.coasts?
            area.coasts.select { |c| position.neighboring_coasts.include?(c) }.map do |coast|
              position_order_map['retreat'] << [[position.area_id, position.coast_id], [area.id, coast.id]]
            end
          else
            position_order_map['retreat'] << [[position.area_id, position.coast_id], [area.id, nil]]
          end
        end
      end
      order_map[position.id] = position_order_map
      order_map
    end
  end

  def self.valid_build_orders(user_game, all_unit_positions, turn)
    positions = user_game.positions.turn(turn)
    builds_available = PositionService.calculate_builds_available(user_game, turn)
    if builds_available > 0
      build_positions = positions.supply_center.no_unit.power(user_game.power)
      build_positions.reduce({}) do |order_map, position|
        position_order_map = {
          'no_build' => [[[position.area_id, position.coast_id], [position.area_id, position.coast_id]]],
          'build_army' => [[[position.area_id, position.coast_id], [position.area_id, position.coast_id]]],
        }
        if position.area.coastal?
          position_order_map['build_fleet'] = if position.area.coast?
            position.area.coasts.map do |coast|
              [[position.area_id, nil], [position.area_id, coast.id]]
            end
          else
            [[[position.area_id, nil], [position.area_id, nil]]]
          end
        end
        order_map[position.id] = position_order_map
        order_map
      end
    else
      positions.with_unit.reduce({}) do |order_map, position|
        order_detail = [[[position.area_id, position.coast_id], [position.area_id, position.coast_id]]]
        order_map[position.id] = {
          'disband' => order_detail,
          'keep' => order_detail,
        }
        order_map
      end
    end
  end

  def self.valid_move_orders(current_position, other_unit_positions)
    PathService.possible_paths(current_position, other_unit_positions).map do |path|
      from = [current_position.area_id, current_position.coast_id]
      to = if path.last.kind_of?(Array)
        [path.last.first.id, path.last.last&.id]
      else
        [path.last.id, nil]
      end
      [from, to]
    end.uniq
  end

  def self.valid_support_orders(current_position, other_unit_positions)
    support_areas = PathService.supportable_areas(current_position)
    other_unit_positions.reduce([]) do |orders, position|
      # allow supporting a position to hold if it is an accessible area
      if support_areas.include?(position.area)
        orders << [[position.area_id, position.coast_id], [position.area_id, position.coast_id]]
      end

      # allow supporting any move from another position to an accessible area
      valid_move_orders(position, other_unit_positions.without(position, current_position)).filter do |details|
        support_areas.map(&:id).include?(details.last.first)
      end.each do |details|
        orders << [[position.area_id, position.coast_id], details.last]
      end
      orders
    end
  end

  def self.valid_convoy_orders(current_position, other_unit_positions)
    raise 'Only fleets may convoy' unless current_position.fleet?
    return [] if AreaService.area_map[current_position.area_id].land?

    coastal_army_positions = other_unit_positions.select do |position|
      position.army? && AreaService.area_map[position.area_id].coastal?
    end

    # filter for all convoyed paths that go through the current position's area
    coastal_army_positions.map do |position|
      remaining_positions = other_unit_positions.without(position).concat([current_position])
      PathService.possible_paths(position, remaining_positions).select do |path|
        path.include?(current_position.area)
      end.map do |path|
        # only want start and destination areas
        [[path.first.id, nil], [path.last.id, nil]]
      end.uniq
    end.flatten(1)
  end
end
