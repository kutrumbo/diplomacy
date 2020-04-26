require 'test_helper'

class OrderServiceTest < ActiveSupport::TestCase
  test "valid_move_orders-fleet" do
    greece = Area.find_by_name('Greece')
    current_position = create(:position, area: greece, type: 'fleet')

    orders = OrderService.valid_move_orders(current_position, [])

    assert_equal(
      [[nil, 'Aegean Sea'], [nil, 'Albania'], [nil, 'Bulgaria'], [nil, 'Ionian Sea']],
      parse_orders(orders),
    )
  end

  test "valid_move_orders-fleet_coast" do
    bulgaria = Area.find_by_name('Bulgaria')
    bulgaria_sc = Coast.find_by(area: bulgaria, direction: 'south')

    current_position = create(:position, area: bulgaria, type: 'fleet', coast: bulgaria_sc)

    orders = OrderService.valid_move_orders(current_position, [])

    assert_equal(
      [[nil, 'Aegean Sea'], [nil, 'Constantinople'], [nil, 'Greece']],
      parse_orders(orders),
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
      [[nil, 'Albania'], [nil, 'Apulia'], [nil, 'Bulgaria'], [nil, 'Constantinople'], [nil, 'Naples'], [nil, 'Serbia'], [nil, 'Smyrna'], [nil, 'Syria'], [nil, 'Tunis']],
      parse_orders(orders),
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
      [[nil, 'Galicia'], [nil, 'Rumania'], [nil, 'Serbia'], [nil, 'Trieste'], [nil, 'Vienna']],
      parse_orders(orders),
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
      [['Aegean Sea', 'Bulgaria'], ['Black Sea', 'Bulgaria'], ['Black Sea', 'Sevastopol'], ['Budapest', 'Budapest'], ['Budapest', 'Galicia'], ['Budapest', 'Serbia'], ['Warsaw', 'Galicia'], ['Warsaw', 'Ukraine']],
      parse_orders(orders),
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
      [['Aegean Sea', 'Aegean Sea'], ['Aegean Sea', 'Constantinople'], ['Aegean Sea', 'Greece'], ['Ankara', 'Constantinople']],
      parse_orders(orders),
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
      [['Greece', 'Albania'], ['Greece', 'Apulia'], ['Greece', 'Bulgaria'], ['Greece', 'Constantinople'], ['Greece', 'Naples'], ['Greece', 'Smyrna'], ['Greece', 'Syria'], ['Greece', 'Tunis'], ['Tunis', 'Bulgaria'], ['Tunis', 'Constantinople'], ['Tunis', 'Greece'], ['Tunis', 'Smyrna'], ['Tunis', 'Syria']],
      parse_orders(orders),
    )
  end

  def parse_orders(orders)
    orders.map do |order|
      [order.first && Area.find(order.first).name, order.last && Area.find(order.last).name]
    end.sort
  end
end
