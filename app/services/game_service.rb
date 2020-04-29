module GameService
  def self.initiate_game(name, users)
    raise 'Requires 7 users' if users.length != 7

    ActiveRecord::Base.transaction do
      game = Game.create!(name: name)
      assign_powers(game, users)
      game.turns.create!(type: 'spring', number: 1)
      create_starting_positions(game)
    end
  end

  def self.declare_winner(user_game)
    user_game.game.update!(user_game: user_game)
  end

  private

  def self.assign_powers(game, users)
    powers = UserGame::POWER_TYPES.dup
    users.map do |user|
      game.user_games.create!(user: user, game: game, power: powers.delete(powers.sample))
    end
  end

  def self.create_starting_positions(game)
    turn = game.turns.first
    game.user_games.each do |user_game|
      Area.starting_power(user_game.power).each do |area|
        coast = Coast.find_by(area: area, direction: area.coast)
        turn.positions.create!(
          type: area.unit,
          area: area,
          coast: coast,
          user_game: user_game,
          power: user_game.power,
          dislodged: false,
        )
      end
    end
    turn.positions.each do |position|
      PositionService.prepare_order(position)
    end
  end
end
