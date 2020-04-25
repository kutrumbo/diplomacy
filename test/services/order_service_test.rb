require 'test_helper'

class OrderServiceTest < ActiveSupport::TestCase
  parallelize_setup do |worker|
      AreaService.seed_areas
  end

  parallelize_teardown do |worker|
    AreaService.teardown
  end

  test "valid_move_destinations-fleet" do
    greece = Area.find_by_name('Greece')
    current_position = create(:position, area: greece, type: 'fleet')

    destinations = OrderService.valid_move_orders(current_position, [])

    assert_equal(['Aegean Sea', 'Albania', 'Bulgaria', 'Ionian Sea'], destinations.pluck(:name).sort)
  end

  test "valid_move_destinations-army" do
    greece = Area.find_by_name('Greece')
    aegean_sea = Area.find_by_name('Aegean Sea')
    eastern_med = Area.find_by_name('Eastern Mediterranean')
    ionian_sea = Area.find_by_name('Ionian Sea')
    current_position = create(:position, area: greece, type: 'army')
    aegean_fleet = create(:position, area: aegean_sea, type: 'fleet')
    eastern_med_fleet = create(:position, area: eastern_med, type: 'fleet')
    ionian_sea_fleet = create(:position, area: ionian_sea, type: 'fleet')

    destinations = OrderService.valid_move_orders(current_position, [aegean_fleet, eastern_med_fleet, ionian_sea_fleet])

    assert_equal([
      'Albania', 'Apulia', 'Bulgaria', 'Constantinople', 'Naples', 'Serbia', 'Smyrna', 'Syria', 'Tunis'
      ], destinations.pluck(:name).sort)
  end
end
