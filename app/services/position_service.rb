module PositionService
  def self.process_orders(order_resolutions, current_turn, upcoming_turn)
    order_resolutions.each do |resolution, orders|
      orders.each do |order|
        process_order(order, resolution, upcoming_turn)
      end
    end

    new_positions = upcoming_turn.positions.includes_areas
    # loop through previous positions to see if any other positions need to be created
    current_turn.positions.includes_areas.each do |previous_position|
      if current_turn.attack?
        process_previous_attack_position(previous_position, new_positions, upcoming_turn)
      else
        unless previous_position.dislodged?
          new_position = previous_position.dup
          new_position.update!(turn: upcoming_turn)
        end
      end
    end
    if current_turn.fall_retreat?
      current_turn.reload.positions.with_unit.each do |position|
        position.update!(power: position.user_game.power)
      end
    end
  end

  def self.process_previous_attack_position(previous_position, new_positions, upcoming_turn)
    # there can be multiple new positions on an area in cases of dislodgement
    next_positions = new_positions.select do |p|
      previous_position.area == p.area
    end

    if next_positions.empty? && previous_position.power?
      new_position = previous_position.dup
      # if no new positions and previous position was claimed, create new position
      new_position.update!(turn: upcoming_turn, type: nil)
    end
  end

  # create a new position based on the order resolution
  def self.process_order(order, resolution, upcoming_turn)
    next_position = order.position.dup
    next_position.type = order.position.type
    next_position.turn = upcoming_turn
    next_position.power = order.power if upcoming_turn.build?

    case resolution
    when :resolved
      if order.move? || order.retreat?
        next_position.update!(area: order.to)
      elsif order.build_fleet?
        next_position.update!(type: 'fleet')
      elsif order.build_army?
        next_position.update!(type: 'army')
      else
        next_position.save! unless (order.disband? || order.no_build?)
      end
    when :dislodged
      next_position.update!(dislodged: true, power: nil)
    when :cancelled, :invalid, :bounced
      next_position.save!
    when :failed
      # Retreat failed so don't save new position
    else
      raise 'Unsupported resolution'
    end
  end

  def self.prepare_order(position)
    if position.turn.attack?
      create_default_order(position, 'hold') if position.type?
    elsif position.turn.retreat?
      create_default_order(position, 'retreat') if position.dislodged?
    elsif position.turn.build?
      create_default_build_order(position)
    end
  end

  def self.calculate_builds_available(user_game, turn)
    positions = user_game.positions.turn(turn)
    supply_center_count = positions.supply_center.count
    unit_count = positions.with_unit.count
    builds_available = supply_center_count - unit_count
  end

  private

  def self.create_default_order(position, type)
    position.turn.orders.create!(
      type: type,
      user_game: position.user_game,
      from_id: position.area_id,
      to_id: position.area_id,
      confirmed: false,
      position: position,
    )
  end

  def self.create_default_build_order(position)
    builds_available = PositionService.calculate_builds_available(position.user_game, position.turn)
    if builds_available > 0
      if position.type.nil? && position.area.supply_center? && position.area.power == position.user_game.power
        create_default_order(position, 'no_build')
      end
    elsif builds_available < 0
      create_default_order(position, 'disband') if position.type?
    end
  end
end
