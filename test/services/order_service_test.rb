require 'test_helper'

class OrderServiceTest < ActiveSupport::TestCase
  test "valid_move_orders-fleet" do
    greece = Area.find_by_name('Greece')
    current_position = create(:position, area: greece, type: 'fleet')

    orders = OrderService.valid_move_orders(current_position, [])

    assert_equal(
      ['Aegean Sea', 'Albania', 'Bulgaria', 'Ionian Sea'],
      orders.pluck(:name).sort,
    )
  end

  test "valid_move_orders-fleet_coast" do
    bulgaria = Area.find_by_name('Bulgaria')
    bulgaria_sc = Coast.find_by(area: bulgaria, direction: 'south')

    current_position = create(:position, area: bulgaria, type: 'fleet', coast: bulgaria_sc)

    orders = OrderService.valid_move_orders(current_position, [])

    assert_equal(
      ['Aegean Sea', 'Constantinople', 'Greece'],
      orders.pluck(:name).sort,
    )
  end

  test "valid_move_orders-army" do
    greece = Area.find_by_name('Greece')
    aegean_sea = Area.find_by_name('Aegean Sea')
    eastern_med = Area.find_by_name('Eastern Mediterranean')
    ionian_sea = Area.find_by_name('Ionian Sea')

    current_position = create(:position, area: greece, type: 'army')
    aegean_fleet = create(:position, area: aegean_sea, type: 'fleet')
    eastern_med_fleet = create(:position, area: eastern_med, type: 'fleet')
    ionian_sea_fleet = create(:position, area: ionian_sea, type: 'fleet')

    orders = OrderService.valid_move_orders(current_position, [aegean_fleet, eastern_med_fleet, ionian_sea_fleet])

    assert_equal(
      ['Albania', 'Apulia', 'Bulgaria', 'Constantinople', 'Greece', 'Naples', 'Serbia', 'Smyrna', 'Syria', 'Tunis'],
      orders.pluck(:name).sort
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
      orders.map { |order| order.map(&:name) }.sort,
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
      orders.map { |order| order.map(&:name) }.sort,
    )
  end
end
