module TurnService
  def self.process_turn(turn)
    return if turn.nil?
    if complete?(turn)
      process_orders(turn)
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

  def self.process_orders(turn)
    if turn.attack?
      process_attack_orders(turn)
    elsif turn.retreat?
      process_retreat_orders(turn)
    else
      process_build_orders(turn)
    end
  end

  def self.process_attack_orders(turn)
    process_resolutions(resolve_orders(create_support_map(turn.orders)), turn)
  end

  # returns a hash of form { area: { order: supporting_orders }}
  def self.create_support_map(orders)
    support_map = orders.group_by(&:to).reduce({}) do |support_map, (area, orders)|
      support_map[area] = {}
      orders_by_type = orders.group_by(&:type)
      (orders_by_type['hold'] + orders_by_type['move']).each do |order|
        supporting_orders = orders_by_type['support'].select do |support_order|
          support_order.from_id == order.from_id && support_order.to_id == order.to_id
        end
        support_map[area][order] = supporting_orders
      end
      support_map
    end
  end

  def self.resolve_orders(support_map)
    order_resolutions = {
      success: [],
      cut: [],
      bounce: [],
      retreat: [],
      destroy: [],
    }

    order_resolutions
  end

  def self.process_resolutions(order_resolutions, turn)
    unoccupied_positions = turn.positions.unoccupied
    # TODO
    if (next_turn_type == 'winter')
      # TODO
    end
  end

  def self.process_retreat_orders(turn)
    # TODO
  end

  def self.process_build_orders(turn)
    # TODO
  end

  def self.victory?(game)
    # TODO check for resignations
    game.positions.supply_center.group(:user_game_id).count.values.any? do |count|
      count >= 18
    end
  end

  def self.finish_game(game)
    victor_id = turn.positions.supply_center.group(:user_game_id).count.find do |ug_id, count|
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
