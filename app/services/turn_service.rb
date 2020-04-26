module TurnService
  def self.process_turn(turn)
    return if turn.nil?
    if complete?(turn)
      process_orders(turn.orders)
      if victory?(turn.reload)
        finish_game(turn.game)
      else
        create_next_turn(turn)
      end
    end
  end

  def self.complete?(turn)
    !turn.user_games.any?(&:pending?)
  end

  def self.process_orders(orders)
    # TODO
  end

  def self.victory?(game)
    # TODO check for resignations
    game.positions.owns_supply_center.group(:user_game_id).count.values.any? do |count|
      count >= 18
    end
  end

  def self.finish_game(game)
    victor_id = turn.positions.owns_supply_center.group(:user_game_id).count.find do |ug_id, count|
      count >= 18
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
