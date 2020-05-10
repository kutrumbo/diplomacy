module TurnService
  WINNING_SUPPLY_CENTER_AMOUNT = 18

  def self.process_turn(turn)
    return if turn.number < turn.game.current_turn.number
    if turn_complete?(turn)
      OrderResolutionService.new(turn).resolve_orders

      next_turn = create_next_turn(turn.reload)
      PositionService.process_resolutions(
        turn,
        next_turn,
      )

      if user_game_id = determine_victor(next_turn)
        UserGame.find(user_game_id).update!(winner: true)
      else
        next_turn.reload.positions.each do |position|
          PositionService.prepare_order(position)
        end
        if next_turn.reload.orders.empty?
          # no orders possible, so proceed to next turn
          TurnService.process_turn(next_turn)
        end
      end
    end
  end

  def self.determine_victor(next_turn)
    next_turn.positions.occupied.supply_center.group(:user_game_id).count.find do |_, count|
      count >= 18
    end&.first
  end

  def self.turn_complete?(turn)
    turn.orders.all?(&:confirmed)
  end

  def self.create_next_turn(turn)
    turn.game.turns.create!(
      number: turn.number + 1,
      type: next_turn_type(turn),
    )
  end

  def self.next_turn_type(turn)
    {
      spring: 'spring_retreat',
      spring_retreat: 'fall',
      fall: 'fall_retreat',
      fall_retreat: 'winter',
      winter: 'spring',
    }[turn.type.to_sym]
  end
end
