module GameService
  def self.initiate_game(name, users)
    raise 'Requires 7 users' if users.length != 7

    ActiveRecord::Base.transaction do
      game = Game.create!(name: name)
      assign_powers(game, users)
      create_starting_positions(game)
      game.turns.create!(type: 'fall', number: 1)
    end
  end

  private

  def self.assign_powers(game, users)
    powers = UserGame::POWER_TYPES.dup
    game.user_games << users.map do |user|
      UserGame.create!(user: user, game: game, power: powers.delete(powers.sample))
    end
  end

  def self.create_starting_positions(game)
    game.user_games.each do |user_game|
      Area.starting_power(user_game.power).each do |area|
        coast = Coast.find_by(area: area, direction: area.coast)
        user_game.positions.create!(type: area.unit, area: area, coast: coast)
      end
    end
  end
end
