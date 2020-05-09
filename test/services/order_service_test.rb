require 'test_helper'

class OrderServiceTest < ActiveSupport::TestCase
  test "valid_move_orders-fleet" do
    greece = Area.find_by_name('Greece')
    current_position = create(:position, area: greece, type: 'fleet')

    orders = OrderService.valid_move_orders(current_position, [])

    assert_equal(
      [[['Greece', nil], ['Aegean Sea', nil]], [['Greece', nil], ['Albania', nil]], [['Greece', nil], ['Bulgaria', 'south']], [['Greece', nil], ['Ionian Sea', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_move_orders-fleet_area_with_coasts" do
    bulgaria = Area.find_by_name('Bulgaria')
    bulgaria_sc = Coast.find_by(area: bulgaria, direction: 'south')

    current_position = create(:position, area: bulgaria, type: 'fleet', coast: bulgaria_sc)

    orders = OrderService.valid_move_orders(current_position, [])

    assert_equal(
      [[['Bulgaria', 'south'], ['Aegean Sea', nil]], [['Bulgaria', 'south'], ['Constantinople', nil]], [['Bulgaria', 'south'], ['Greece', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_move_orders-fleet_coastal_without_coasts" do
    rome = Area.find_by_name('Rome')

    current_position = create(:position, area: rome, type: 'fleet')

    orders = OrderService.valid_move_orders(current_position, [])

    assert_equal(
      [[['Rome', nil], ['Naples', nil]], [['Rome', nil], ['Tuscany', nil]], [['Rome', nil], ['Tyrrhenian Sea', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_move_orders-army_coast" do
    greece = Area.find_by_name('Greece')
    aegean_sea = Area.find_by_name('Aegean Sea')
    eastern_med = Area.find_by_name('Eastern Mediterranean')
    ionian_sea = Area.find_by_name('Ionian Sea')

    aegean_fleet = create(:position, area: aegean_sea, type: 'fleet')
    eastern_med_fleet = create(:position, area: eastern_med, type: 'fleet')
    ionian_sea_fleet = create(:position, area: ionian_sea, type: 'fleet')

    current_position = create(:position, area: greece, type: 'army')

    orders = OrderService.valid_move_orders(current_position, [aegean_fleet, eastern_med_fleet, ionian_sea_fleet])

    assert_equal(
      [[['Greece', nil], ['Albania', nil]], [['Greece', nil], ['Apulia', nil]], [['Greece', nil], ['Bulgaria', nil]], [['Greece', nil], ['Constantinople', nil]], [['Greece', nil], ['Naples', nil]], [['Greece', nil], ['Serbia', nil]], [['Greece', nil], ['Smyrna', nil]], [['Greece', nil], ['Syria', nil]], [['Greece', nil], ['Tunis', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_move_orders-army_landlocked" do
    budapest = Area.find_by_name('Budapest')
    vienna = Area.find_by_name('Vienna')
    trieste = Area.find_by_name('Trieste')

    trieste_fleet = create(:position, area: trieste, type: 'fleet')
    vienna_army = create(:position, area: vienna, type: 'army')

    current_position = create(:position, area: budapest, type: 'army')

    orders = OrderService.valid_move_orders(current_position, [trieste_fleet, vienna_army])

    assert_equal(
      [[['Budapest', nil], ['Galicia', nil]], [['Budapest', nil], ['Rumania', nil]], [['Budapest', nil], ['Serbia', nil]], [['Budapest', nil], ['Trieste', nil]], [['Budapest', nil], ['Vienna', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_support_orders-army" do
    warsaw = Area.find_by_name('Warsaw')
    rumania = Area.find_by_name('Rumania')
    budapest = Area.find_by_name('Budapest')
    black_sea = Area.find_by_name('Black Sea')
    aegean_sea = Area.find_by_name('Aegean Sea')

    black_sea_fleet = create(:position, area: black_sea, type: 'fleet')
    aegean_sea_fleet = create(:position, area: aegean_sea, type: 'fleet')
    budapest_army = create(:position, area: budapest, type: 'army')
    warsaw_army = create(:position, area: warsaw, type: 'army')

    current_position = create(:position, area: rumania, type: 'army')

    orders = OrderService.valid_support_orders(current_position, [aegean_sea_fleet, black_sea_fleet, budapest_army, warsaw_army])

    assert_equal(
      [[['Aegean Sea', nil], ['Bulgaria', 'south']], [['Black Sea', nil], ['Bulgaria', 'east']], [['Black Sea', nil], ['Sevastopol', nil]], [['Budapest', nil], ['Budapest', nil]], [['Budapest', nil], ['Galicia', nil]], [['Budapest', nil], ['Serbia', nil]], [['Warsaw', nil], ['Galicia', nil]], [['Warsaw', nil], ['Ukraine', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_support_orders-fleet" do
    ukraine = Area.find_by_name('Ukraine')
    ankara = Area.find_by_name('Ankara')
    bulgaria = Area.find_by_name('Bulgaria')
    bulgaria_sc = Coast.find_by(area: bulgaria, direction: 'south')
    aegean_sea = Area.find_by_name('Aegean Sea')

    ukraine_army = create(:position, area: ukraine, type: 'army')
    ankara_army = create(:position, area: ankara, type: 'army')
    aegean_sea_fleet = create(:position, area: aegean_sea, type: 'fleet')

    current_position = create(:position, area: bulgaria, type: 'fleet', coast: bulgaria_sc)

    orders = OrderService.valid_support_orders(current_position, [aegean_sea_fleet, ankara_army, ukraine_army])

    assert_equal(
      [[['Aegean Sea', nil], ['Aegean Sea', nil]], [['Aegean Sea', nil], ['Constantinople', nil]], [['Aegean Sea', nil], ['Greece', nil]], [['Ankara', nil], ['Constantinople', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_convoy_orders" do
    greece = Area.find_by_name('Greece')
    tunis = Area.find_by_name('Tunis')
    aegean_sea = Area.find_by_name('Aegean Sea')
    eastern_med = Area.find_by_name('Eastern Mediterranean')
    ionian_sea = Area.find_by_name('Ionian Sea')

    eastern_med_fleet = create(:position, area: eastern_med, type: 'fleet')
    ionian_sea_fleet = create(:position, area: ionian_sea, type: 'fleet')
    greece_army = create(:position, area: greece, type: 'army')
    tunis_army = create(:position, area: tunis, type: 'army')

    current_position = create(:position, area: aegean_sea, type: 'fleet')

    orders = OrderService.valid_convoy_orders(current_position, [eastern_med_fleet, greece_army, ionian_sea_fleet, tunis_army])

    assert_equal(
      [[['Greece', nil], ['Albania', nil]], [['Greece', nil], ['Apulia', nil]], [['Greece', nil], ['Bulgaria', nil]], [['Greece', nil], ['Constantinople', nil]], [['Greece', nil], ['Naples', nil]], [['Greece', nil], ['Smyrna', nil]], [['Greece', nil], ['Syria', nil]], [['Greece', nil], ['Tunis', nil]], [['Tunis', nil], ['Bulgaria', nil]], [['Tunis', nil], ['Constantinople', nil]], [['Tunis', nil], ['Greece', nil]], [['Tunis', nil], ['Smyrna', nil]], [['Tunis', nil], ['Syria', nil]]],
      parse_order_results(orders),
    )
  end

  test "valid_retreat_orders" do
    previous_turn = create(:turn, type: 'spring', number: 6)
    turn = create(:turn, type: 'spring_retreat', number: 7, game: previous_turn.game)
    austria = create(:user_game, game: turn.game, power: 'austria')
    turkey = create(:user_game, game: turn.game, power: 'turkey')

    budapest = Area.find_by_name('Budapest')
    galicia = Area.find_by_name('Galicia')
    vienna = Area.find_by_name('Vienna')

    prev_budapest_position = create(:position, area: budapest, type: 'army', turn: previous_turn, user_game: turkey)
    prev_galicia_position = create(:position, area: galicia, type: 'army', turn: previous_turn, user_game: austria)
    prev_vienna_position = create(:position, area: vienna, type: 'army', turn: previous_turn, user_game: austria)

    move = create(:order, type: 'move', from: vienna, to: budapest, position: prev_vienna_position, turn: previous_turn, user_game: austria)
    support = create(:order, type: 'support', from: vienna, to: budapest, position: prev_galicia_position, turn: previous_turn, user_game: austria)
    dislodged = create(:order, type: 'move', from: budapest, to: galicia, position: prev_budapest_position, turn: previous_turn, user_game: turkey)

    create(:resolution, order: move, status: 'resolved')
    create(:resolution, order: support, status: 'resolved')
    create(:resolution, order: dislodged, status: 'dislodged')

    budapest_position = create(:position, area: budapest, type: 'army', turn: turn, user_game: turkey, dislodged: true)
    galicia_position = create(:position, area: galicia, type: 'army', turn: turn, user_game: austria)
    vienna_position = create(:position, area: budapest, type: 'army', turn: turn, user_game: austria)

    retreat_options = OrderService.valid_retreat_orders(turkey, turn.positions, turn)
    assert_equal([[['Budapest', nil], ['Budapest', nil]]], parse_order_results(retreat_options[budapest_position.id]['disband']))
    assert_equal([[['Budapest', nil], ['Rumania', nil]], [['Budapest', nil], ['Serbia', nil]], [['Budapest', nil], ['Trieste', nil]]], parse_order_results(retreat_options[budapest_position.id]['retreat']))
  end

  private

  def parse_order_results(orders)
    orders.map do |order|
      from = [Area.find(order.first.first).name, Coast.find_by(id: order.first.last)&.direction]
      to = [Area.find(order.last.first).name, Coast.find_by(id: order.last.last)&.direction]
      [from, to]
    end.sort_by { |pairs| pairs.flatten }
  end
end
