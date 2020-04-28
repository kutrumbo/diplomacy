module PositionService
  def self.process_orders(order_resolutions, current_turn, upcoming_turn)
    order_resolutions.each do |resolution, orders|
      orders.each do |order|
        process_order(order, resolution, upcoming_turn)
      end
    end

    new_positions = upcoming_turn.positions
    # loop through previous positions to see if any other positions need to be created
    current_turn.positions.each do |previous_position|
      if current_turn.attack?
        process_previous_attack_position(previous_position, new_positions, upcoming_turn)
      else
        new_position = previous_position.dup
        new_position.update!(turn: upcoming_turn)
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
      if order.move?
        next_position.update!(area: order.to)
      else
        next_position.save!
      end
    when :dislodged
      next_position.update!(dislodged: true, power: nil)
    when :cancelled, :invalid, :bounced
      next_position.save!
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
      create_default_order(position, 'build_army') if supports_build(position)
    end
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

  def self.supports_build(position)
    # TODO: calculate if user gets any builds
    position.power == position.area.power && position.type? && position.area.supply_center?
  end
end
