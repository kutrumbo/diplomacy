module TurnService
  WINNING_SUPPLY_CENTER_AMOUNT = 18

  def self.process_turn(turn)
    return if turn.nil?
    if complete?(turn)
      if turn.attack?
        resolve_attack_orders(turn)
      elsif turn.retreat?
        # TODO resolve retreats
      else
        # TODO resolve builds
      end
      if victory?(turn.reload)
        finish_game(turn.game)
      else
        create_next_turn(turn)
      end
    end
  end

  def self.resolve_attack_orders(turn)
    order_resolutions = turn.orders.group_by { |o| OrderService.resolve(o).first }
    PositionService.process_attack_orders(positions, order_resolutions)
  end

  def self.complete?(turn)
    !turn.user_games.any?(&:pending?)
  end

  def self.victory?(game)
    # TODO check for resignations
    game.positions.supply_center.group(:user_game_id).size.values.any? do |size|
      size >= WINNING_SUPPLY_CENTER_AMOUNT
    end
  end

  def self.finish_game(game)
    victor_id = turn.positions.supply_center.group(:user_game_id).size.find do |ug_id, size|
      size >= WINNING_SUPPLY_CENTER_AMOUNT
    end.first
    victor = UserGame.find(victor_id)
    # TODO
  end

  def self.create_next_turn(turn)
    turn.game.turns.create!(number: turn.number + 1, type: next_turn_type(turn))
  end

  def self.next_turn_type(turn)
    if require_retreat?(turn)
      "#{turn.type}_retreat"
    else
      {
        spring: 'fall',
        spring_retreat: 'fall',
        fall: 'winter',
        fall_retreat: 'winter',
        winter: 'spring',
      }[turn.type.to_sym]
    end
  end

  def self.require_retreat?(turn)
    return false if ['', '', ''].include?(turn.type)
    turn.positions.any?(&:retreat?)
  end
end
