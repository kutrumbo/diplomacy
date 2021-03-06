module PositionService
  def self.process_resolutions(current_turn, upcoming_turn)
    current_turn.orders.each do |order|
      raise 'Order is not resolved' if order.resolution.nil?
      process_resolution(order.resolution, upcoming_turn)
    end

    new_positions = upcoming_turn.positions.includes_areas
    # loop through previous positions to see if any other positions need to be created
    current_turn.positions.includes_areas.each do |previous_position|
      process_previous_position(previous_position, new_positions, upcoming_turn, current_turn)
    end
    # if it is the end of fall, claim any occupied positions
    if current_turn.retreat?
      upcoming_turn.reload.positions.includes(:area, :user_game).group_by(&:area).each do |area, positions|
        raise 'Cannot be more than 2 positions on an area' if positions.size > 2
        positions_with_unit = positions.select(&:type)
        raise 'Can only be one position with a unit on a territory' if positions_with_unit.size > 1
        if position_with_unit = positions_with_unit.first
          # if there is a position with a unit, other positon is removed
          positions.reject(&:type).first&.destroy

          # if fall turn, area is claimed
          if current_turn.fall_retreat? && position_with_unit.power != position_with_unit.user_game.power
            position_with_unit.update!(power: position_with_unit.user_game.power)
          end
        end
      end
    end
  end

  def self.process_previous_position(previous_position, new_positions, upcoming_turn, current_turn)
    if current_turn.attack?
      process_previous_attack_position(previous_position, new_positions, upcoming_turn)
    elsif current_turn.retreat?
      process_previous_retreat_position(previous_position, new_positions, upcoming_turn)
    elsif current_turn.build?
      process_previous_build_position(previous_position, new_positions, upcoming_turn)
    else
      raise 'Unsupported turn type'
    end
  end

  def self.process_previous_attack_position(previous_position, new_positions, upcoming_turn)
    previous_area_power = previous_position.power
    # return if area was not occupied previous turn
    return if previous_area_power.nil?

    previous_position_power = previous_position.user_game.power
    # return if this position was not the occupying power last turn
    return if previous_position_power != previous_area_power

    # there can be multiple new positions on an area in cases of dislodgement
    next_positions_on_area = new_positions.select do |p|
      previous_position.area == p.area
    end
    # return if unit of same power is one of next positions
    return if next_positions_on_area.any? do |p|
      p.user_game.power == previous_area_power && p.type.present?
    end

    new_position = previous_position.dup
    new_position.update!(turn: upcoming_turn, type: nil, coast: nil)
  end

  # create new positions for all old positions except ones that were dislodged
  def self.process_previous_retreat_position(previous_position, new_positions, upcoming_turn)
    unless previous_position.dislodged?
      new_position = previous_position.dup
      new_position.update!(turn: upcoming_turn)
    end
  end

  # create new positions for all old positions except for areas where new position was created
  def self.process_previous_build_position(previous_position, new_positions, upcoming_turn)
    unless new_positions.any? { |p| p.area == previous_position.area }
      new_position = previous_position.dup
      new_position.update!(turn: upcoming_turn)
    end
  end

  # create a new position based on the order resolution
  def self.process_resolution(resolution, upcoming_turn)
    order = resolution.order
    next_position = order.position.dup
    next_position.type = order.position.type
    next_position.turn = upcoming_turn

    case resolution.status
    when 'resolved'
      if order.move? || order.retreat?
        areas_previous_power = order.turn.positions.find { |p| order.to == p.area }&.power
        next_position.update!(area: order.to, coast: order.to_coast, power: areas_previous_power, dislodged: false)
      elsif order.build_fleet?
        next_position.update!(type: 'fleet', coast: order.to_coast)
      elsif order.build_army?
        next_position.update!(type: 'army')
      elsif order.support? || order.convoy? || order.hold? || order.keep?
        next_position.save!
      elsif order.disband? || order.no_build?
        next_position.update!(type: nil, dislodged: false)
      else
        raise "Not implemented: resolved order of type: #{order.type}"
      end
    when 'dislodged'
      next_position.update!(dislodged: true)
    when 'cancelled', 'invalid', 'bounced', 'broken', 'cut'
      next_position.save!
    when 'failed'
      # Retreat failed so don't save new position
    else
      raise 'Unsupported resolution'
    end
  end

  def self.prepare_order(position)
    if position.turn.attack?
      create_default_order(position, 'hold') if position.type?
    elsif position.turn.retreat?
      create_default_order(position, 'disband') if position.dislodged?
    elsif position.turn.build?
      create_default_build_order(position)
    end
  end

  def self.calculate_builds_available(user_game, turn)
    positions = user_game.positions.turn(turn)
    supply_center_count = positions.supply_center.count
    unit_count = positions.with_unit.count
    max_builds = Area.supply_center.starting_power(user_game.power).count
    builds_available = [supply_center_count - unit_count, max_builds].min
  end

  private

  def self.create_default_order(position, type, override_coast_id=nil)
    position.turn.orders.create!(
      type: type,
      user_game: position.user_game,
      from_id: position.area_id,
      from_coast_id: override_coast_id || position.coast_id,
      to_id: position.area_id,
      to_coast_id: override_coast_id || position.coast_id,
      confirmed: false,
      position: position,
    )
  end

  def self.create_default_build_order(position)
    builds_available = PositionService.calculate_builds_available(position.user_game, position.turn)
    if builds_available > 0
      if position.type.nil? && position.area.supply_center? && position.area.power == position.user_game.power
        # make sure position is built on coast if Saint Petersburg
        override_coast_id = if position.area.coast?
          Coast.find_by(area: position.area, direction: position.area.coast).id
        else
          nil
        end
        create_default_order(position, 'no_build', override_coast_id)
      end
    elsif builds_available < 0
      create_default_order(position, 'keep') if position.type?
    end
  end
end
