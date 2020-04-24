module AreaService
  def self.seed_areas
    # Create Areas
    Area.create!(name: 'Ankara', type: 'land', supply_center: true, power: 'turkey')
    Area.create!(name: 'Belgium', type: 'land', supply_center: true)
    Area.create!(name: 'Berlin', type: 'land', supply_center: true, power: 'germany')
    Area.create!(name: 'Brest', type: 'land', supply_center: true, power: 'france')
    Area.create!(name: 'Budapest', type: 'land', supply_center: true, power: 'austria')
    Area.create!(name: 'Bulgaria', type: 'land', supply_center: true)
    Area.create!(name: 'Constantinople', type: 'land', supply_center: true, power: 'turkey')
    Area.create!(name: 'Denmark', type: 'land', supply_center: true)
    Area.create!(name: 'Edinburgh', type: 'land', supply_center: true, power: 'england')
    Area.create!(name: 'Greece', type: 'land', supply_center: true)
    Area.create!(name: 'Holland', type: 'land', supply_center: true)
    Area.create!(name: 'Kiel', type: 'land', supply_center: true, power: 'germany')
    Area.create!(name: 'Liverpool', type: 'land', supply_center: true, power: 'england')
    Area.create!(name: 'London', type: 'land', supply_center: true, power: 'england')
    Area.create!(name: 'Marseilles', type: 'land', supply_center: true, power: 'france')
    Area.create!(name: 'Moscow', type: 'land', supply_center: true, power: 'russia')
    Area.create!(name: 'Munich', type: 'land', supply_center: true, power: 'germany')
    Area.create!(name: 'Naples', type: 'land', supply_center: true, power: 'italy')
    Area.create!(name: 'Norway', type: 'land', supply_center: true)
    Area.create!(name: 'Paris', type: 'land', supply_center: true, power: 'france')
    Area.create!(name: 'Portugal', type: 'land', supply_center: true)
    Area.create!(name: 'Rome', type: 'land', supply_center: true, power: 'italy')
    Area.create!(name: 'Rumania', type: 'land', supply_center: true)
    Area.create!(name: 'Saint Petersburg', type: 'land', supply_center: true, power: 'russia')
    Area.create!(name: 'Serbia', type: 'land', supply_center: true)
    Area.create!(name: 'Sevastopol', type: 'land', supply_center: true, power: 'russia')
    Area.create!(name: 'Smyrna', type: 'land', supply_center: true, power: 'turkey')
    Area.create!(name: 'Spain', type: 'land', supply_center: true)
    Area.create!(name: 'Sweden', type: 'land', supply_center: true)
    Area.create!(name: 'Trieste', type: 'land', supply_center: true, power: 'austria')
    Area.create!(name: 'Tunis', type: 'land', supply_center: true)
    Area.create!(name: 'Venice', type: 'land', supply_center: true, power: 'italy')
    Area.create!(name: 'Vienna', type: 'land', supply_center: true, power: 'austria')
    Area.create!(name: 'Warsaw', type: 'land', supply_center: true, power: 'russia')
    Area.create!(name: 'Clyde', type: 'land', supply_center: false)
    Area.create!(name: 'Yorkshire', type: 'land', supply_center: false)
    Area.create!(name: 'Wales', type: 'land', supply_center: false)
    Area.create!(name: 'Picardy', type: 'land', supply_center: false)
    Area.create!(name: 'Gascony', type: 'land', supply_center: false)
    Area.create!(name: 'Burgundy', type: 'land', supply_center: false)
    Area.create!(name: 'North Africa', type: 'land', supply_center: false)
    Area.create!(name: 'Ruhr', type: 'land', supply_center: false)
    Area.create!(name: 'Prussia', type: 'land', supply_center: false)
    Area.create!(name: 'Silesia', type: 'land', supply_center: false)
    Area.create!(name: 'Piedmont', type: 'land', supply_center: false)
    Area.create!(name: 'Tuscany', type: 'land', supply_center: false)
    Area.create!(name: 'Apulia', type: 'land', supply_center: false)
    Area.create!(name: 'Tyrolia', type: 'land', supply_center: false)
    Area.create!(name: 'Galicia', type: 'land', supply_center: false)
    Area.create!(name: 'Bohemia', type: 'land', supply_center: false)
    Area.create!(name: 'Finland', type: 'land', supply_center: false)
    Area.create!(name: 'Livonia', type: 'land', supply_center: false)
    Area.create!(name: 'Ukraine', type: 'land', supply_center: false)
    Area.create!(name: 'Albania', type: 'land', supply_center: false)
    Area.create!(name: 'Armenia', type: 'land', supply_center: false)
    Area.create!(name: 'Syria', type: 'land', supply_center: false)
    Area.create!(name: 'North Atlantic Ocean', type: 'sea', supply_center: false)
    Area.create!(name: 'Mid Atlantic Ocean', type: 'sea', supply_center: false)
    Area.create!(name: 'Norwegian Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'North Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'English Channel', type: 'sea', supply_center: false)
    Area.create!(name: 'Irish Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'Heligoland Bight', type: 'sea', supply_center: false)
    Area.create!(name: 'Skagerrack', type: 'sea', supply_center: false)
    Area.create!(name: 'Baltic Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'Gulf of Bothnia', type: 'sea', supply_center: false)
    Area.create!(name: 'Barents Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'Western Mediterranean', type: 'sea', supply_center: false)
    Area.create!(name: 'Gulf of Lyons', type: 'sea', supply_center: false)
    Area.create!(name: 'Tyrrhenian Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'Ionian Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'Adriatic Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'Aegean Sea', type: 'sea', supply_center: false)
    Area.create!(name: 'Eastern Mediterranean', type: 'sea', supply_center: false)
    Area.create!(name: 'Black Sea', type: 'sea', supply_center: false)

    # Create coasts
    Coast.create!(area: Area.find_by_name('Saint Petersburg'), direction: 'north')
    Coast.create!(area: Area.find_by_name('Saint Petersburg'), direction: 'south')
    Coast.create!(area: Area.find_by_name('Spain'), direction: 'north')
    Coast.create!(area: Area.find_by_name('Spain'), direction: 'south')
    Coast.create!(area: Area.find_by_name('Bulgaria'), direction: 'south')
    Coast.create!(area: Area.find_by_name('Bulgaria'), direction: 'east')

    # Create neighbor mappings
  end

  def self.teardown
    Neighbor.destroy_all
    Coast.destroy_all
    Area.destroy_all
  end
end
