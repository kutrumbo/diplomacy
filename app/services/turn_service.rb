module TurnService
  WINNING_SUPPLY_CENTER_AMOUNT = 18

  def self.process_turn(turn)
    return if turn.number < turn.game.current_turn.number
    if turn_complete?(turn)
      order_resolutions = turn.orders.group_by do |o|
        OrderService.resolve(o).first
      end

      next_turn = create_next_turn(turn)
      PositionService.process_orders(
        order_resolutions,
        turn,
        next_turn,
      )

      if victor = determine_victor(next_turn)
        # TODO
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
    next_turn.positions.occupied.supply_center.group(:user_game_id).count.any? do |_, count|
      count >= 18
    end
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
