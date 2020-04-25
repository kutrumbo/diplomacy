module GameService
  def self.initiate_game(name, users)
    raise 'Requires 7 users' if users.length != 7

    ActiveRecord::Base.transaction do
      game = Game.create!(name: name)
      assign_powers(game, users)
      Turn.create!(type: 'fall', number: 1, game: game)
      create_starting_positions(game)
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
      case user_game.power
      when 'austria'
        Position.create!(type: 'army', area: Area.find_by_name('Budapest'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Vienna'), user_game: user_game)
        Position.create!(type: 'fleet', area: Area.find_by_name('Trieste'), user_game: user_game)
      when 'england'
        Position.create!(type: 'fleet', area: Area.find_by_name('Edinburgh'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Liverpool'), user_game: user_game)
        Position.create!(type: 'fleet', area: Area.find_by_name('London'), user_game: user_game)
      when 'france'
        Position.create!(type: 'fleet', area: Area.find_by_name('Brest'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Marseilles'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Paris'), user_game: user_game)
      when 'germany'
        Position.create!(type: 'army', area: Area.find_by_name('Berlin'), user_game: user_game)
        Position.create!(type: 'fleet', area: Area.find_by_name('Kiel'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Munich'), user_game: user_game)
      when 'italy'
        Position.create!(type: 'army', area: Area.find_by_name('Venice'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Rome'), user_game: user_game)
        Position.create!(type: 'fleet', area: Area.find_by_name('Naples'), user_game: user_game)
      when 'russia'
        Position.create!(type: 'army', area: Area.find_by_name('Moscow'), user_game: user_game)
        saint_petersburg = Area.find_by_name('Saint Petersburg')
        south_coast = Coast.find_by(area: saint_petersburg, direction: 'south')
        Position.create!(type: 'fleet', area: saint_petersburg, coast: south_coast, user_game: user_game)
        Position.create!(type: 'fleet', area: Area.find_by_name('Sevastopol'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Warsaw'), user_game: user_game)
      when 'turkey'
        Position.create!(type: 'fleet', area: Area.find_by_name('Ankara'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Constantinople'), user_game: user_game)
        Position.create!(type: 'army', area: Area.find_by_name('Smyrna'), user_game: user_game)
      end
    end
  end
end
