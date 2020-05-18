require 'test_helper'

class OrderResolutionServiceTest < ActiveSupport::TestCase

  def setup
    @attack_turn = create(:turn, type: 'spring')
    @retreat_turn = create(:turn, type: 'spring_retreat')
    @england = create(:user_game, power: 'england')
    @france = create(:user_game, power: 'france')
    @albania = Area.find_by_name('Albania')
    @budapest = Area.find_by_name('Budapest')
    @bulgaria = Area.find_by_name('Bulgaria')
    @constantinople = Area.find_by_name('Constantinople')
    @greece = Area.find_by_name('Greece')
    @rumania = Area.find_by_name('Rumania')
    @serbia = Area.find_by_name('Serbia')
  end

  def create_position(area, type, user_game=nil, turn=nil)
    create(:position, area: area, type: type, turn: turn || @attack_turn, user_game: user_game || create(:user_game))
  end

  def create_hold(position)
    create(:order, type: 'hold', position: position, from: position.area, to: position.area, turn: position.turn, user_game: position.user_game)
  end

  def create_move(position, to)
    create(:order, type: 'move', position: position, from: position.area, to: to, turn: position.turn, user_game: position.user_game)
  end

  def create_support(position, from, to)
    create(:order, type: 'support', position: position, from: from, to: to, turn: position.turn, user_game: position.user_game)
  end

  def create_convoy(position, from, to)
    create(:order, type: 'convoy', position: position, from: from, to: to, turn: position.turn, user_game: position.user_game)
  end

  def create_retreat(position, to)
    create(:order, type: 'retreat', position: position, from: position.area, to: to, turn: position.turn, user_game: position.user_game)
  end

  test "invalid support" do
    greece_position = create_position(@greece, 'army')
    serbia_position = create_position(@serbia, 'army')

    move_order = create_move(serbia_position, @albania)
    support_order = create_support(greece_position, @serbia, @bulgaria)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('invalid', resolutions[support_order].status)
  end

  test "simple successful support" do
    albania_position = create_position(@albania, 'army', @england)
    greece_position = create_position(@greece, 'army', @england)
    serbia_position = create_position(@serbia, 'army', @france)

    o1 = create_move(albania_position, @serbia)
    o2 = create_support(greece_position, @albania, @serbia)
    o3 = create_move(serbia_position, @greece)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('resolved', resolutions[o1].status)
    assert_equal('resolved', resolutions[o2].status)
    assert_equal('dislodged', resolutions[o3].status)
  end

  test "simple two position train" do
    albania_position = create_position(@albania, 'army')
    serbia_position = create_position(@serbia, 'army')

    o1 = create_move(albania_position, @serbia)
    o2 = create_move(serbia_position, @greece)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('resolved', resolutions[o1].status)
    assert_equal('resolved', resolutions[o2].status)
  end

  test "two units can't swap" do
    albania_position = create_position(@albania, 'army')
    serbia_position = create_position(@serbia, 'army')

    o1 = create_move(albania_position, @serbia)
    o2 = create_move(serbia_position, @albania)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('bounced', resolutions[o1].status)
    assert_equal('bounced', resolutions[o2].status)
  end

  test "three-way rotation is permitted" do
    albania_position = create_position(@albania, 'army')
    greece_position = create_position(@greece, 'army')
    serbia_position = create_position(@serbia, 'army')

    o1 = create_move(albania_position, @serbia)
    o2 = create_move(serbia_position, @greece)
    o3 = create_move(greece_position, @albania)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('resolved', resolutions[o1].status)
    assert_equal('resolved', resolutions[o2].status)
    assert_equal('resolved', resolutions[o3].status)
  end

  test "loops and chain movements" do
    albania_position = create_position(@albania, 'army')
    bulgaria_position = create_position(@bulgaria, 'army')
    constantinople_position = create_position(@constantinople, 'army')
    greece_position = create_position(@greece, 'army')
    serbia_position = create_position(@serbia, 'army')

    o1 = create_move(albania_position, @serbia)
    o2 = create_move(serbia_position, @greece)
    o3 = create_move(greece_position, @albania)
    o4 = create_move(bulgaria_position, @constantinople)
    o5 = create_hold(constantinople_position)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('resolved', resolutions[o1].status)
    assert_equal('resolved', resolutions[o2].status)
    assert_equal('resolved', resolutions[o3].status)
    assert_equal('bounced', resolutions[o4].status)
    assert_equal('resolved', resolutions[o5].status)
  end

  test "resolve-cut_support" do
    budapest_position = create_position(@budapest, 'army', @england)
    bulgaria_position = create_position(@bulgaria, 'army', @england)
    serbia_position = create_position(@serbia, 'army', @france)
    rumania_position = create_position(@rumania, 'army', @france)

    o1 = create_move(bulgaria_position, @rumania)
    o2 = create_move(serbia_position, @budapest)
    o3 = create_support(budapest_position, @bulgaria, @rumania)
    o4 = create_hold(rumania_position)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('bounced', resolutions[o1].status)
    assert_equal('bounced', resolutions[o2].status)
    assert_equal('cut', resolutions[o3].status)
    assert_equal('resolved', resolutions[o4].status)
  end

  test "power cannot dislodged itself" do
    budapest_position = create_position(@budapest, 'army', @england)
    bulgaria_position = create_position(@bulgaria, 'army', @england)
    rumania_position = create_position(@rumania, 'army', @england)

    attack = create_move(bulgaria_position, @rumania)
    support = create_support(budapest_position, @bulgaria, @rumania)
    hold = create_hold(rumania_position)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('bounced', resolutions[attack].status)
    assert_equal('resolved', resolutions[support].status)
    assert_equal('resolved', resolutions[hold].status)
  end

  test "bounce train" do
    albania_position = create_position(@albania, 'army')
    serbia_position = create_position(@serbia, 'army')
    bulgaria_position = create_position(@bulgaria, 'army')
    rumania_position = create_position(@rumania, 'army')

    o1 = create_hold(albania_position)
    o2 = create_move(serbia_position, @albania)
    o3 = create_move(bulgaria_position, @serbia)
    o4 = create_move(rumania_position, @bulgaria)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('resolved', resolutions[o1].status)
    assert_equal('bounced', resolutions[o2].status)
    assert_equal('bounced', resolutions[o3].status)
    assert_equal('bounced', resolutions[o4].status)
  end

  test "resolve retreats" do
    serbia_position = create_position(@serbia, 'army', @france, @retreat_turn)
    rumania_position = create_position(@rumania, 'army', @england, @retreat_turn)
    constantinople_position = create_position(@constantinople, 'fleet', @england, @retreat_turn)

    o1 = create_retreat(serbia_position, @serbia)
    o2 = create_retreat(rumania_position, @serbia)
    o3 = create_retreat(constantinople_position, @bulgaria)

    resolutions = OrderResolutionService.new(@retreat_turn).resolve_orders

    assert_equal('failed', resolutions[o1].status)
    assert_equal('failed', resolutions[o2].status)
    assert_equal('resolved', resolutions[o3].status)
  end

  #
  # test "resolve-convoy" do
  #   turn = create(:turn)
  #   tunis = Area.find_by_name('Tunis')
  #   ionian_sea = Area.find_by_name('Ionian Sea')
  #   aegean_sea = Area.find_by_name('Aegean Sea')
  #   smyrna = Area.find_by_name('Smyrna')
  #
  #   tunis_position = create(:position, area: tunis, type: 'army', turn: turn)
  #   ionian_sea_position = create(:position, area: ionian_sea, type: 'fleet', turn: turn)
  #   aegean_sea_position = create(:position, area: aegean_sea, type: 'fleet', turn: turn)
  #
  #   move = create(:order, type: 'move', from: tunis, to: smyrna, position: tunis_position, turn: turn)
  #   convoy1 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: ionian_sea_position, turn: turn)
  #   convoy2 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: aegean_sea_position, turn: turn)
  #
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move))
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy1))
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy2))
  # end
  #
  # test "resolve-convoy_bounce" do
  #   turn = create(:turn)
  #   tunis = Area.find_by_name('Tunis')
  #   ionian_sea = Area.find_by_name('Ionian Sea')
  #   aegean_sea = Area.find_by_name('Aegean Sea')
  #   smyrna = Area.find_by_name('Smyrna')
  #
  #   tunis_position = create(:position, area: tunis, type: 'army', turn: turn)
  #   ionian_sea_position = create(:position, area: ionian_sea, type: 'fleet', turn: turn)
  #   aegean_sea_position = create(:position, area: aegean_sea, type: 'fleet', turn: turn)
  #   smyrna_position = create(:position, area: smyrna, type: 'fleet', turn: turn)
  #
  #   move = create(:order, type: 'move', from: tunis, to: smyrna, position: tunis_position, turn: turn)
  #   convoy1 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: ionian_sea_position, turn: turn)
  #   convoy2 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: aegean_sea_position, turn: turn)
  #   hold = create(:order, type: 'hold', from: smyrna, to: smyrna, position: smyrna_position, turn: turn)
  #
  #   assert_equal([:bounced], OrderResolutionService.new(turn).resolve(move))
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy1))
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy2))
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(hold))
  # end
  #
  # test "resolve-convoy_disrupted" do
  #   turn = create(:turn)
  #   england = create(:user_game, power: 'england')
  #   germany = create(:user_game, power: 'germany')
  #   tunis = Area.find_by_name('Tunis')
  #   ionian_sea = Area.find_by_name('Ionian Sea')
  #   aegean_sea = Area.find_by_name('Aegean Sea')
  #   smyrna = Area.find_by_name('Smyrna')
  #   adriatic_sea = Area.find_by_name('Adriatic Sea')
  #   tyrrhenian_sea = Area.find_by_name('Tyrrhenian Sea')
  #
  #   tunis_position = create(:position, area: tunis, type: 'army', user_game: england, turn: turn)
  #   ionian_sea_position = create(:position, area: ionian_sea, type: 'fleet', user_game: england, turn: turn)
  #   aegean_sea_position = create(:position, area: aegean_sea, type: 'fleet', user_game: england, turn: turn)
  #   adriatic_sea_position = create(:position, area: adriatic_sea, type: 'fleet', user_game: germany, turn: turn)
  #   tyrrhenian_sea_position = create(:position, area: tyrrhenian_sea, type: 'fleet', user_game: germany, turn: turn)
  #
  #   move = create(:order, type: 'move', from: tunis, to: smyrna, position: tunis_position, user_game: england, turn: turn)
  #   convoy1 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: ionian_sea_position, user_game: england, turn: turn)
  #   convoy2 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: aegean_sea_position, user_game: england, turn: turn)
  #   attack_convoy = create(:order, type: 'move', from: adriatic_sea, to: ionian_sea, position: adriatic_sea_position, user_game: germany, turn: turn)
  #   support_attack = create(:order, type: 'support', from: adriatic_sea, to: ionian_sea, position: tyrrhenian_sea_position, user_game: germany, turn: turn)
  #
  #   assert_equal([:cancelled], OrderResolutionService.new(turn).resolve(move))
  #   assert_equal([:dislodged, attack_convoy], OrderResolutionService.new(turn).resolve(convoy1))
  #   assert_equal([:cancelled], OrderResolutionService.new(turn).resolve(convoy2))
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(attack_convoy))
  #   assert_equal([:resolved], OrderResolutionService.new(turn).resolve(support_attack))
  # end
end
