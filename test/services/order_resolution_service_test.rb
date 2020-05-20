require 'test_helper'

class OrderResolutionServiceTest < ActiveSupport::TestCase

  def setup
    @attack_turn = create(:turn, type: 'spring')
    @retreat_turn = create(:turn, type: 'spring_retreat')
    @england = create(:user_game, power: 'england')
    @france = create(:user_game, power: 'france')
    @aegean_sea = Area.find_by_name('Aegean Sea')
    @albania = Area.find_by_name('Albania')
    @budapest = Area.find_by_name('Budapest')
    @bulgaria = Area.find_by_name('Bulgaria')
    @constantinople = Area.find_by_name('Constantinople')
    @eastern_mediterranean = Area.find_by_name('Eastern Mediterranean')
    @greece = Area.find_by_name('Greece')
    @ionian_sea = Area.find_by_name('Ionian Sea')
    @rumania = Area.find_by_name('Rumania')
    @serbia = Area.find_by_name('Serbia')
    @smyrna = Area.find_by_name('Smyrna')
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

  test "simple convoy" do
    greece_position = create_position(@greece, 'army')
    aegean_sea_position = create_position(@aegean_sea, 'fleet')

    o1 = create_move(greece_position, @smyrna)
    o2 = create_convoy(aegean_sea_position, @greece, @smyrna)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('resolved', resolutions[o1].status)
    assert_equal('resolved', resolutions[o2].status)
  end

  test "disrupted convoy" do
    aegean_sea_position = create_position(@aegean_sea, 'fleet', @england)
    eastern_mediterranean_position = create_position(@eastern_mediterranean, 'fleet', @france)
    greece_position = create_position(@greece, 'army', @england)
    ionian_sea_position = create_position(@ionian_sea, 'fleet', @france)

    o1 = create_move(greece_position, @smyrna)
    o2 = create_convoy(aegean_sea_position, @greece, @smyrna)
    o3 = create_move(eastern_mediterranean_position, @aegean_sea)
    o4 = create_support(ionian_sea_position, @eastern_mediterranean, @aegean_sea)

    resolutions = OrderResolutionService.new(@attack_turn).resolve_orders

    assert_equal('failed', resolutions[o1].status)
    assert_equal('dislodged', resolutions[o2].status)
    assert_equal('resolved', resolutions[o3].status)
    assert_equal('resolved', resolutions[o4].status)
  end
end
