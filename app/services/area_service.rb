module AreaService
  def self.area_map
    @@area_map ||= Area.all.index_by(&:id)
    @@area_map
  end

  def self.neighboring_areas_map
    @@neighboring_areas_map ||= Area.all.includes(:neighboring_areas).reduce({}) do |map, area|
      map[area] = area.neighboring_areas.to_a
      map
    end
    @@neighboring_areas_map
  end

  def self.neighboring_coasts_map
    @@neighboring_coasts_map ||= Area.all.includes(:neighboring_coasts).reduce({}) do |map, area|
      map[area] = area.neighboring_coasts.to_a
      map
    end
    @@neighboring_coasts_map
  end

  def self.seed_areas
    # Create Areas
    ankara = Area.create!(name: 'Ankara', type: 'land', supply_center: true, power: 'turkey', unit: 'fleet')
    belgium = Area.create!(name: 'Belgium', type: 'land', supply_center: true)
    berlin = Area.create!(name: 'Berlin', type: 'land', supply_center: true, power: 'germany', unit: 'army')
    brest = Area.create!(name: 'Brest', type: 'land', supply_center: true, power: 'france', unit: 'fleet')
    budapest = Area.create!(name: 'Budapest', type: 'land', supply_center: true, power: 'austria', unit: 'army')
    bulgaria = Area.create!(name: 'Bulgaria', type: 'land', supply_center: true)
    constantinople = Area.create!(name: 'Constantinople', type: 'land', supply_center: true, power: 'turkey', unit: 'army')
    denmark = Area.create!(name: 'Denmark', type: 'land', supply_center: true)
    edinburgh = Area.create!(name: 'Edinburgh', type: 'land', supply_center: true, power: 'england', unit: 'fleet')
    greece = Area.create!(name: 'Greece', type: 'land', supply_center: true)
    holland = Area.create!(name: 'Holland', type: 'land', supply_center: true)
    kiel = Area.create!(name: 'Kiel', type: 'land', supply_center: true, power: 'germany', unit: 'fleet')
    liverpool = Area.create!(name: 'Liverpool', type: 'land', supply_center: true, power: 'england', unit: 'army')
    london = Area.create!(name: 'London', type: 'land', supply_center: true, power: 'england', unit: 'fleet')
    marseilles = Area.create!(name: 'Marseilles', type: 'land', supply_center: true, power: 'france', unit: 'army')
    moscow = Area.create!(name: 'Moscow', type: 'land', supply_center: true, power: 'russia', unit: 'army')
    munich = Area.create!(name: 'Munich', type: 'land', supply_center: true, power: 'germany', unit: 'army')
    naples = Area.create!(name: 'Naples', type: 'land', supply_center: true, power: 'italy', unit: 'fleet')
    norway = Area.create!(name: 'Norway', type: 'land', supply_center: true)
    paris = Area.create!(name: 'Paris', type: 'land', supply_center: true, power: 'france', unit: 'army')
    portugal = Area.create!(name: 'Portugal', type: 'land', supply_center: true)
    rome = Area.create!(name: 'Rome', type: 'land', supply_center: true, power: 'italy', unit: 'army')
    rumania = Area.create!(name: 'Rumania', type: 'land', supply_center: true)
    saint_petersburg = Area.create!(name: 'Saint Petersburg', type: 'land', supply_center: true, power: 'russia', unit: 'fleet', coast: 'south')
    serbia = Area.create!(name: 'Serbia', type: 'land', supply_center: true)
    sevastopol = Area.create!(name: 'Sevastopol', type: 'land', supply_center: true, power: 'russia', unit: 'fleet')
    smyrna = Area.create!(name: 'Smyrna', type: 'land', supply_center: true, power: 'turkey', unit: 'army')
    spain = Area.create!(name: 'Spain', type: 'land', supply_center: true)
    sweden = Area.create!(name: 'Sweden', type: 'land', supply_center: true)
    trieste = Area.create!(name: 'Trieste', type: 'land', supply_center: true, power: 'austria', unit: 'fleet')
    tunis = Area.create!(name: 'Tunis', type: 'land', supply_center: true)
    venice = Area.create!(name: 'Venice', type: 'land', supply_center: true, power: 'italy', unit: 'army')
    vienna = Area.create!(name: 'Vienna', type: 'land', supply_center: true, power: 'austria', unit: 'army')
    warsaw = Area.create!(name: 'Warsaw', type: 'land', supply_center: true, power: 'russia', unit: 'army')
    clyde = Area.create!(name: 'Clyde', type: 'land', supply_center: false, power: 'england')
    yorkshire = Area.create!(name: 'Yorkshire', type: 'land', supply_center: false, power: 'england')
    wales = Area.create!(name: 'Wales', type: 'land', supply_center: false, power: 'england')
    picardy = Area.create!(name: 'Picardy', type: 'land', supply_center: false, power: 'france')
    gascony = Area.create!(name: 'Gascony', type: 'land', supply_center: false, power: 'france')
    burgundy = Area.create!(name: 'Burgundy', type: 'land', supply_center: false, power: 'france')
    north_africa = Area.create!(name: 'North Africa', type: 'land', supply_center: false)
    ruhr = Area.create!(name: 'Ruhr', type: 'land', supply_center: false, power: 'germany')
    prussia = Area.create!(name: 'Prussia', type: 'land', supply_center: false, power: 'germany')
    silesia = Area.create!(name: 'Silesia', type: 'land', supply_center: false, power: 'germany')
    piedmont = Area.create!(name: 'Piedmont', type: 'land', supply_center: false, power: 'italy')
    tuscany = Area.create!(name: 'Tuscany', type: 'land', supply_center: false, power: 'italy')
    apulia = Area.create!(name: 'Apulia', type: 'land', supply_center: false, power: 'italy')
    tyrolia = Area.create!(name: 'Tyrolia', type: 'land', supply_center: false, power: 'austria')
    galicia = Area.create!(name: 'Galicia', type: 'land', supply_center: false, power: 'austria')
    bohemia = Area.create!(name: 'Bohemia', type: 'land', supply_center: false, power: 'austria')
    finland = Area.create!(name: 'Finland', type: 'land', supply_center: false, power: 'russia')
    livonia = Area.create!(name: 'Livonia', type: 'land', supply_center: false, power: 'russia')
    ukraine = Area.create!(name: 'Ukraine', type: 'land', supply_center: false, power: 'russia')
    albania = Area.create!(name: 'Albania', type: 'land', supply_center: false)
    armenia = Area.create!(name: 'Armenia', type: 'land', supply_center: false, power: 'turkey')
    syria = Area.create!(name: 'Syria', type: 'land', supply_center: false, power: 'turkey')
    north_atlantic_ocean = Area.create!(name: 'North Atlantic Ocean', type: 'sea', supply_center: false)
    mid_atlantic_ocean = Area.create!(name: 'Mid Atlantic Ocean', type: 'sea', supply_center: false)
    norwegian_sea = Area.create!(name: 'Norwegian Sea', type: 'sea', supply_center: false)
    north_sea = Area.create!(name: 'North Sea', type: 'sea', supply_center: false)
    english_channel = Area.create!(name: 'English Channel', type: 'sea', supply_center: false)
    irish_sea = Area.create!(name: 'Irish Sea', type: 'sea', supply_center: false)
    heligoland_bight = Area.create!(name: 'Heligoland Bight', type: 'sea', supply_center: false)
    skagerrack = Area.create!(name: 'Skagerrack', type: 'sea', supply_center: false)
    baltic_sea = Area.create!(name: 'Baltic Sea', type: 'sea', supply_center: false)
    gulf_of_bothnia = Area.create!(name: 'Gulf of Bothnia', type: 'sea', supply_center: false)
    barents_sea = Area.create!(name: 'Barents Sea', type: 'sea', supply_center: false)
    western_mediterranean = Area.create!(name: 'Western Mediterranean', type: 'sea', supply_center: false)
    gulf_of_lyons = Area.create!(name: 'Gulf of Lyons', type: 'sea', supply_center: false)
    tyrrhenian_sea = Area.create!(name: 'Tyrrhenian Sea', type: 'sea', supply_center: false)
    ionian_sea = Area.create!(name: 'Ionian Sea', type: 'sea', supply_center: false)
    adriatic_sea = Area.create!(name: 'Adriatic Sea', type: 'sea', supply_center: false)
    aegean_sea = Area.create!(name: 'Aegean Sea', type: 'sea', supply_center: false)
    eastern_mediterranean = Area.create!(name: 'Eastern Mediterranean', type: 'sea', supply_center: false)
    black_sea = Area.create!(name: 'Black Sea', type: 'sea', supply_center: false)

    # Create coasts
    saint_petersburg_nc = Coast.create!(area: saint_petersburg, direction: 'north')
    saint_petersburg_sc = Coast.create!(area: saint_petersburg, direction: 'south')
    spain_nc = Coast.create!(area: spain, direction: 'north')
    spain_sc = Coast.create!(area: spain, direction: 'south')
    bulgaria_sc = Coast.create!(area: bulgaria, direction: 'south')
    bulgaria_ec = Coast.create!(area: bulgaria, direction: 'east')

    # Create border mappings
    Border.create!(area: ankara, neighbor: black_sea)
    Border.create!(area: ankara, neighbor: armenia, coastal: true)
    Border.create!(area: ankara, neighbor: smyrna)
    Border.create!(area: ankara, neighbor: constantinople, coastal: true)

    Border.create!(area: belgium, neighbor: english_channel)
    Border.create!(area: belgium, neighbor: north_sea)
    Border.create!(area: belgium, neighbor: holland, coastal: true)
    Border.create!(area: belgium, neighbor: ruhr)
    Border.create!(area: belgium, neighbor: burgundy)
    Border.create!(area: belgium, neighbor: picardy, coastal: true)

    Border.create!(area: berlin, neighbor: baltic_sea)
    Border.create!(area: berlin, neighbor: prussia, coastal: true)
    Border.create!(area: berlin, neighbor: silesia)
    Border.create!(area: berlin, neighbor: munich)
    Border.create!(area: berlin, neighbor: kiel, coastal: true)

    Border.create!(area: brest, neighbor: english_channel)
    Border.create!(area: brest, neighbor: mid_atlantic_ocean)
    Border.create!(area: brest, neighbor: picardy, coastal: true)
    Border.create!(area: brest, neighbor: paris)
    Border.create!(area: brest, neighbor: gascony, coastal: true)

    Border.create!(area: budapest, neighbor: galicia)
    Border.create!(area: budapest, neighbor: rumania)
    Border.create!(area: budapest, neighbor: serbia)
    Border.create!(area: budapest, neighbor: trieste)
    Border.create!(area: budapest, neighbor: vienna)

    Border.create!(area: bulgaria, neighbor: rumania, coastal: true)
    Border.create!(area: bulgaria, neighbor: black_sea)
    Border.create!(area: bulgaria, neighbor: constantinople, coastal: true)
    Border.create!(area: bulgaria, neighbor: aegean_sea)
    Border.create!(area: bulgaria, neighbor: greece, coastal: true)
    Border.create!(area: bulgaria, neighbor: serbia)

    Border.create!(area: constantinople, neighbor: bulgaria_sc, coastal: true)
    Border.create!(area: constantinople, neighbor: bulgaria, coastal: true)
    Border.create!(area: constantinople, neighbor: bulgaria_ec, coastal: true)
    Border.create!(area: constantinople, neighbor: black_sea)
    Border.create!(area: constantinople, neighbor: ankara, coastal: true)
    Border.create!(area: constantinople, neighbor: smyrna, coastal: true)
    Border.create!(area: constantinople, neighbor: aegean_sea)

    Border.create!(area: denmark, neighbor: skagerrack)
    Border.create!(area: denmark, neighbor: sweden, coastal: true)
    Border.create!(area: denmark, neighbor: baltic_sea)
    Border.create!(area: denmark, neighbor: kiel, coastal: true)
    Border.create!(area: denmark, neighbor: heligoland_bight)
    Border.create!(area: denmark, neighbor: north_sea)

    Border.create!(area: edinburgh, neighbor: norwegian_sea)
    Border.create!(area: edinburgh, neighbor: north_sea)
    Border.create!(area: edinburgh, neighbor: yorkshire, coastal: true)
    Border.create!(area: edinburgh, neighbor: liverpool)
    Border.create!(area: edinburgh, neighbor: clyde, coastal: true)

    Border.create!(area: greece, neighbor: albania, coastal: true)
    Border.create!(area: greece, neighbor: serbia)
    Border.create!(area: greece, neighbor: bulgaria_sc, coastal: true)
    Border.create!(area: greece, neighbor: bulgaria, coastal: true)
    Border.create!(area: greece, neighbor: aegean_sea)
    Border.create!(area: greece, neighbor: ionian_sea)

    Border.create!(area: holland, neighbor: heligoland_bight)
    Border.create!(area: holland, neighbor: kiel, coastal: true)
    Border.create!(area: holland, neighbor: ruhr)
    Border.create!(area: holland, neighbor: belgium, coastal: true)
    Border.create!(area: holland, neighbor: north_sea)

    Border.create!(area: kiel, neighbor: denmark, coastal: true)
    Border.create!(area: kiel, neighbor: baltic_sea)
    Border.create!(area: kiel, neighbor: berlin, coastal: true)
    Border.create!(area: kiel, neighbor: munich)
    Border.create!(area: kiel, neighbor: ruhr)
    Border.create!(area: kiel, neighbor: holland, coastal: true)
    Border.create!(area: kiel, neighbor: heligoland_bight)

    Border.create!(area: liverpool, neighbor: clyde, coastal: true)
    Border.create!(area: liverpool, neighbor: edinburgh)
    Border.create!(area: liverpool, neighbor: yorkshire)
    Border.create!(area: liverpool, neighbor: wales, coastal: true)
    Border.create!(area: liverpool, neighbor: irish_sea)
    Border.create!(area: liverpool, neighbor: north_atlantic_ocean)

    Border.create!(area: london, neighbor: yorkshire, coastal: true)
    Border.create!(area: london, neighbor: north_sea)
    Border.create!(area: london, neighbor: english_channel)
    Border.create!(area: london, neighbor: wales, coastal: true)

    Border.create!(area: marseilles, neighbor: spain_sc, coastal: true)
    Border.create!(area: marseilles, neighbor: spain, coastal: true)
    Border.create!(area: marseilles, neighbor: gascony)
    Border.create!(area: marseilles, neighbor: burgundy)
    Border.create!(area: marseilles, neighbor: piedmont, coastal: true)
    Border.create!(area: marseilles, neighbor: gulf_of_lyons)

    Border.create!(area: moscow, neighbor: saint_petersburg)
    Border.create!(area: moscow, neighbor: sevastopol)
    Border.create!(area: moscow, neighbor: ukraine)
    Border.create!(area: moscow, neighbor: warsaw)
    Border.create!(area: moscow, neighbor: livonia)

    Border.create!(area: munich, neighbor: ruhr)
    Border.create!(area: munich, neighbor: kiel)
    Border.create!(area: munich, neighbor: berlin)
    Border.create!(area: munich, neighbor: silesia)
    Border.create!(area: munich, neighbor: bohemia)
    Border.create!(area: munich, neighbor: tyrolia)
    Border.create!(area: munich, neighbor: burgundy)

    Border.create!(area: naples, neighbor: rome, coastal: true)
    Border.create!(area: naples, neighbor: apulia, coastal: true)
    Border.create!(area: naples, neighbor: ionian_sea)
    Border.create!(area: naples, neighbor: tyrrhenian_sea)

    Border.create!(area: norway, neighbor: saint_petersburg_nc, coastal: true)
    Border.create!(area: norway, neighbor: saint_petersburg, coastal: true)
    Border.create!(area: norway, neighbor: finland)
    Border.create!(area: norway, neighbor: sweden, coastal: true)
    Border.create!(area: norway, neighbor: skagerrack)
    Border.create!(area: norway, neighbor: north_sea)
    Border.create!(area: norway, neighbor: norwegian_sea)
    Border.create!(area: norway, neighbor: barents_sea)

    Border.create!(area: paris, neighbor: picardy)
    Border.create!(area: paris, neighbor: burgundy)
    Border.create!(area: paris, neighbor: gascony)
    Border.create!(area: paris, neighbor: brest)

    Border.create!(area: portugal, neighbor: mid_atlantic_ocean)
    Border.create!(area: portugal, neighbor: spain_nc, coastal: true)
    Border.create!(area: portugal, neighbor: spain, coastal: true)
    Border.create!(area: portugal, neighbor: spain_sc, coastal: true)

    Border.create!(area: rome, neighbor: tuscany, coastal: true)
    Border.create!(area: rome, neighbor: venice)
    Border.create!(area: rome, neighbor: apulia)
    Border.create!(area: rome, neighbor: naples, coastal: true)
    Border.create!(area: rome, neighbor: tyrrhenian_sea)

    Border.create!(area: rumania, neighbor: budapest)
    Border.create!(area: rumania, neighbor: galicia)
    Border.create!(area: rumania, neighbor: ukraine)
    Border.create!(area: rumania, neighbor: sevastopol, coastal: true)
    Border.create!(area: rumania, neighbor: black_sea)
    Border.create!(area: rumania, neighbor: bulgaria_ec, coastal: true)
    Border.create!(area: rumania, neighbor: bulgaria, coastal: true)
    Border.create!(area: rumania, neighbor: serbia)

    Border.create!(area: saint_petersburg, neighbor: moscow)
    Border.create!(area: saint_petersburg, neighbor: livonia, coastal: true)
    Border.create!(area: saint_petersburg, neighbor: gulf_of_bothnia)
    Border.create!(area: saint_petersburg, neighbor: finland, coastal: true)
    Border.create!(area: saint_petersburg, neighbor: norway, coastal: true)
    Border.create!(area: saint_petersburg, neighbor: barents_sea)

    Border.create!(area: serbia, neighbor: trieste)
    Border.create!(area: serbia, neighbor: budapest)
    Border.create!(area: serbia, neighbor: rumania)
    Border.create!(area: serbia, neighbor: bulgaria)
    Border.create!(area: serbia, neighbor: greece)
    Border.create!(area: serbia, neighbor: albania)

    Border.create!(area: sevastopol, neighbor: ukraine)
    Border.create!(area: sevastopol, neighbor: moscow)
    Border.create!(area: sevastopol, neighbor: armenia, coastal: true)
    Border.create!(area: sevastopol, neighbor: black_sea)
    Border.create!(area: sevastopol, neighbor: rumania, coastal: true)

    Border.create!(area: smyrna, neighbor: constantinople, coastal: true)
    Border.create!(area: smyrna, neighbor: ankara)
    Border.create!(area: smyrna, neighbor: armenia)
    Border.create!(area: smyrna, neighbor: syria, coastal: true)
    Border.create!(area: smyrna, neighbor: eastern_mediterranean)
    Border.create!(area: smyrna, neighbor: aegean_sea)

    Border.create!(area: spain, neighbor: gascony, coastal: true)
    Border.create!(area: spain, neighbor: marseilles, coastal: true)
    Border.create!(area: spain, neighbor: gulf_of_lyons)
    Border.create!(area: spain, neighbor: western_mediterranean)
    Border.create!(area: spain, neighbor: portugal, coastal: true)
    Border.create!(area: spain, neighbor: mid_atlantic_ocean)

    Border.create!(area: sweden, neighbor: norway, coastal: true)
    Border.create!(area: sweden, neighbor: finland, coastal: true)
    Border.create!(area: sweden, neighbor: gulf_of_bothnia)
    Border.create!(area: sweden, neighbor: baltic_sea)
    Border.create!(area: sweden, neighbor: denmark, coastal: true)
    Border.create!(area: sweden, neighbor: skagerrack)

    Border.create!(area: trieste, neighbor: venice, coastal: true)
    Border.create!(area: trieste, neighbor: tyrolia)
    Border.create!(area: trieste, neighbor: vienna)
    Border.create!(area: trieste, neighbor: budapest)
    Border.create!(area: trieste, neighbor: serbia)
    Border.create!(area: trieste, neighbor: albania, coastal: true)
    Border.create!(area: trieste, neighbor: adriatic_sea)

    Border.create!(area: tunis, neighbor: north_africa, coastal: true)
    Border.create!(area: tunis, neighbor: western_mediterranean)
    Border.create!(area: tunis, neighbor: tyrrhenian_sea)
    Border.create!(area: tunis, neighbor: ionian_sea)

    Border.create!(area: venice, neighbor: apulia, coastal: true)
    Border.create!(area: venice, neighbor: rome)
    Border.create!(area: venice, neighbor: tuscany)
    Border.create!(area: venice, neighbor: piedmont)
    Border.create!(area: venice, neighbor: tyrolia)
    Border.create!(area: venice, neighbor: trieste, coastal: true)
    Border.create!(area: venice, neighbor: adriatic_sea)

    Border.create!(area: vienna, neighbor: tyrolia)
    Border.create!(area: vienna, neighbor: bohemia)
    Border.create!(area: vienna, neighbor: galicia)
    Border.create!(area: vienna, neighbor: budapest)
    Border.create!(area: vienna, neighbor: trieste)

    Border.create!(area: warsaw, neighbor: silesia)
    Border.create!(area: warsaw, neighbor: prussia)
    Border.create!(area: warsaw, neighbor: livonia)
    Border.create!(area: warsaw, neighbor: moscow)
    Border.create!(area: warsaw, neighbor: ukraine)
    Border.create!(area: warsaw, neighbor: galicia)

    Border.create!(area: clyde, neighbor: edinburgh, coastal: true)
    Border.create!(area: clyde, neighbor: liverpool, coastal: true)
    Border.create!(area: clyde, neighbor: north_atlantic_ocean)
    Border.create!(area: clyde, neighbor: norwegian_sea)

    Border.create!(area: yorkshire, neighbor: london, coastal: true)
    Border.create!(area: yorkshire, neighbor: wales)
    Border.create!(area: yorkshire, neighbor: liverpool)
    Border.create!(area: yorkshire, neighbor: edinburgh, coastal: true)
    Border.create!(area: yorkshire, neighbor: north_sea)

    Border.create!(area: wales, neighbor: liverpool, coastal: true)
    Border.create!(area: wales, neighbor: yorkshire)
    Border.create!(area: wales, neighbor: london, coastal: true)
    Border.create!(area: wales, neighbor: english_channel)
    Border.create!(area: wales, neighbor: irish_sea)

    Border.create!(area: picardy, neighbor: belgium, coastal: true)
    Border.create!(area: picardy, neighbor: burgundy)
    Border.create!(area: picardy, neighbor: paris)
    Border.create!(area: picardy, neighbor: brest, coastal: true)
    Border.create!(area: picardy, neighbor: english_channel)

    Border.create!(area: gascony, neighbor: brest, coastal: true)
    Border.create!(area: gascony, neighbor: paris)
    Border.create!(area: gascony, neighbor: burgundy)
    Border.create!(area: gascony, neighbor: marseilles)
    Border.create!(area: gascony, neighbor: spain, coastal: true)
    Border.create!(area: gascony, neighbor: spain_nc, coastal: true)
    Border.create!(area: gascony, neighbor: mid_atlantic_ocean)

    Border.create!(area: burgundy, neighbor: belgium)
    Border.create!(area: burgundy, neighbor: ruhr)
    Border.create!(area: burgundy, neighbor: munich)
    Border.create!(area: burgundy, neighbor: marseilles)
    Border.create!(area: burgundy, neighbor: gascony)
    Border.create!(area: burgundy, neighbor: paris)
    Border.create!(area: burgundy, neighbor: picardy)

    Border.create!(area: north_africa, neighbor: mid_atlantic_ocean)
    Border.create!(area: north_africa, neighbor: western_mediterranean)
    Border.create!(area: north_africa, neighbor: tunis, coastal: true)

    Border.create!(area: ruhr, neighbor: belgium)
    Border.create!(area: ruhr, neighbor: holland)
    Border.create!(area: ruhr, neighbor: kiel)
    Border.create!(area: ruhr, neighbor: munich)
    Border.create!(area: ruhr, neighbor: burgundy)

    Border.create!(area: prussia, neighbor: livonia, coastal: true)
    Border.create!(area: prussia, neighbor: warsaw)
    Border.create!(area: prussia, neighbor: silesia)
    Border.create!(area: prussia, neighbor: berlin, coastal: true)
    Border.create!(area: prussia, neighbor: baltic_sea)

    Border.create!(area: silesia, neighbor: munich)
    Border.create!(area: silesia, neighbor: berlin)
    Border.create!(area: silesia, neighbor: prussia)
    Border.create!(area: silesia, neighbor: warsaw)
    Border.create!(area: silesia, neighbor: galicia)
    Border.create!(area: silesia, neighbor: bohemia)

    Border.create!(area: piedmont, neighbor: marseilles, coastal: true)
    Border.create!(area: piedmont, neighbor: tyrolia)
    Border.create!(area: piedmont, neighbor: venice)
    Border.create!(area: piedmont, neighbor: tuscany, coastal: true)
    Border.create!(area: piedmont, neighbor: gulf_of_lyons)

    Border.create!(area: tuscany, neighbor: piedmont, coastal: true)
    Border.create!(area: tuscany, neighbor: venice)
    Border.create!(area: tuscany, neighbor: rome, coastal: true)
    Border.create!(area: tuscany, neighbor: tyrrhenian_sea)
    Border.create!(area: tuscany, neighbor: gulf_of_lyons)

    Border.create!(area: apulia, neighbor: naples, coastal: true)
    Border.create!(area: apulia, neighbor: rome)
    Border.create!(area: apulia, neighbor: venice, coastal: true)
    Border.create!(area: apulia, neighbor: adriatic_sea)
    Border.create!(area: apulia, neighbor: ionian_sea)

    Border.create!(area: tyrolia, neighbor: munich)
    Border.create!(area: tyrolia, neighbor: bohemia)
    Border.create!(area: tyrolia, neighbor: vienna)
    Border.create!(area: tyrolia, neighbor: trieste)
    Border.create!(area: tyrolia, neighbor: venice)
    Border.create!(area: tyrolia, neighbor: piedmont)

    Border.create!(area: galicia, neighbor: warsaw)
    Border.create!(area: galicia, neighbor: ukraine)
    Border.create!(area: galicia, neighbor: rumania)
    Border.create!(area: galicia, neighbor: budapest)
    Border.create!(area: galicia, neighbor: vienna)
    Border.create!(area: galicia, neighbor: bohemia)
    Border.create!(area: galicia, neighbor: silesia)

    Border.create!(area: bohemia, neighbor: munich)
    Border.create!(area: bohemia, neighbor: silesia)
    Border.create!(area: bohemia, neighbor: galicia)
    Border.create!(area: bohemia, neighbor: vienna)
    Border.create!(area: bohemia, neighbor: tyrolia)

    Border.create!(area: finland, neighbor: sweden, coastal: true)
    Border.create!(area: finland, neighbor: norway)
    Border.create!(area: finland, neighbor: saint_petersburg, coastal: true)
    Border.create!(area: finland, neighbor: saint_petersburg_sc, coastal: true)
    Border.create!(area: finland, neighbor: gulf_of_bothnia)

    Border.create!(area: livonia, neighbor: saint_petersburg_sc, coastal: true)
    Border.create!(area: livonia, neighbor: saint_petersburg, coastal: true)
    Border.create!(area: livonia, neighbor: moscow)
    Border.create!(area: livonia, neighbor: warsaw)
    Border.create!(area: livonia, neighbor: prussia, coastal: true)
    Border.create!(area: livonia, neighbor: baltic_sea)
    Border.create!(area: livonia, neighbor: gulf_of_bothnia)

    Border.create!(area: ukraine, neighbor: warsaw)
    Border.create!(area: ukraine, neighbor: moscow)
    Border.create!(area: ukraine, neighbor: sevastopol)
    Border.create!(area: ukraine, neighbor: rumania)
    Border.create!(area: ukraine, neighbor: galicia)

    Border.create!(area: albania, neighbor: trieste, coastal: true)
    Border.create!(area: albania, neighbor: serbia)
    Border.create!(area: albania, neighbor: greece, coastal: true)
    Border.create!(area: albania, neighbor: ionian_sea)
    Border.create!(area: albania, neighbor: adriatic_sea)

    Border.create!(area: armenia, neighbor: sevastopol, coastal: true)
    Border.create!(area: armenia, neighbor: syria)
    Border.create!(area: armenia, neighbor: smyrna)
    Border.create!(area: armenia, neighbor: ankara, coastal: true)
    Border.create!(area: armenia, neighbor: black_sea)

    Border.create!(area: syria, neighbor: smyrna, coastal: true)
    Border.create!(area: syria, neighbor: armenia)
    Border.create!(area: syria, neighbor: eastern_mediterranean)

    Border.create!(area: north_atlantic_ocean, neighbor: norwegian_sea)
    Border.create!(area: north_atlantic_ocean, neighbor: clyde, coastal: true)
    Border.create!(area: north_atlantic_ocean, neighbor: liverpool, coastal: true)
    Border.create!(area: north_atlantic_ocean, neighbor: irish_sea)
    Border.create!(area: north_atlantic_ocean, neighbor: mid_atlantic_ocean)

    Border.create!(area: mid_atlantic_ocean, neighbor: north_atlantic_ocean)
    Border.create!(area: mid_atlantic_ocean, neighbor: irish_sea)
    Border.create!(area: mid_atlantic_ocean, neighbor: english_channel)
    Border.create!(area: mid_atlantic_ocean, neighbor: western_mediterranean)
    Border.create!(area: mid_atlantic_ocean, neighbor: brest, coastal: true)
    Border.create!(area: mid_atlantic_ocean, neighbor: gascony, coastal: true)
    Border.create!(area: mid_atlantic_ocean, neighbor: spain_nc, coastal: true)
    Border.create!(area: mid_atlantic_ocean, neighbor: spain, coastal: true)
    Border.create!(area: mid_atlantic_ocean, neighbor: spain_sc, coastal: true)
    Border.create!(area: mid_atlantic_ocean, neighbor: portugal, coastal: true)
    Border.create!(area: mid_atlantic_ocean, neighbor: north_africa, coastal: true)

    Border.create!(area: norwegian_sea, neighbor: north_atlantic_ocean)
    Border.create!(area: norwegian_sea, neighbor: barents_sea)
    Border.create!(area: norwegian_sea, neighbor: norway, coastal: true)
    Border.create!(area: norwegian_sea, neighbor: north_sea)
    Border.create!(area: norwegian_sea, neighbor: edinburgh, coastal: true)
    Border.create!(area: norwegian_sea, neighbor: clyde, coastal: true)

    Border.create!(area: north_sea, neighbor: norwegian_sea)
    Border.create!(area: north_sea, neighbor: norway, coastal: true)
    Border.create!(area: north_sea, neighbor: skagerrack)
    Border.create!(area: north_sea, neighbor: denmark, coastal: true)
    Border.create!(area: north_sea, neighbor: heligoland_bight)
    Border.create!(area: north_sea, neighbor: holland, coastal: true)
    Border.create!(area: north_sea, neighbor: belgium, coastal: true)
    Border.create!(area: north_sea, neighbor: english_channel)
    Border.create!(area: north_sea, neighbor: london, coastal: true)
    Border.create!(area: north_sea, neighbor: yorkshire, coastal: true)
    Border.create!(area: north_sea, neighbor: edinburgh, coastal: true)

    Border.create!(area: english_channel, neighbor: mid_atlantic_ocean)
    Border.create!(area: english_channel, neighbor: irish_sea)
    Border.create!(area: english_channel, neighbor: wales, coastal: true)
    Border.create!(area: english_channel, neighbor: london, coastal: true)
    Border.create!(area: english_channel, neighbor: north_sea)
    Border.create!(area: english_channel, neighbor: belgium, coastal: true)
    Border.create!(area: english_channel, neighbor: picardy, coastal: true)
    Border.create!(area: english_channel, neighbor: brest, coastal: true)

    Border.create!(area: irish_sea, neighbor: liverpool, coastal: true)
    Border.create!(area: irish_sea, neighbor: wales, coastal: true)
    Border.create!(area: irish_sea, neighbor: english_channel)
    Border.create!(area: irish_sea, neighbor: mid_atlantic_ocean)
    Border.create!(area: irish_sea, neighbor: north_atlantic_ocean)

    Border.create!(area: heligoland_bight, neighbor: north_sea)
    Border.create!(area: heligoland_bight, neighbor: denmark, coastal: true)
    Border.create!(area: heligoland_bight, neighbor: kiel, coastal: true)
    Border.create!(area: heligoland_bight, neighbor: holland, coastal: true)

    Border.create!(area: skagerrack, neighbor: north_sea)
    Border.create!(area: skagerrack, neighbor: norway, coastal: true)
    Border.create!(area: skagerrack, neighbor: sweden, coastal: true)
    Border.create!(area: skagerrack, neighbor: denmark, coastal: true)

    Border.create!(area: baltic_sea, neighbor: denmark, coastal: true)
    Border.create!(area: baltic_sea, neighbor: sweden, coastal: true)
    Border.create!(area: baltic_sea, neighbor: gulf_of_bothnia)
    Border.create!(area: baltic_sea, neighbor: livonia, coastal: true)
    Border.create!(area: baltic_sea, neighbor: prussia, coastal: true)
    Border.create!(area: baltic_sea, neighbor: berlin, coastal: true)
    Border.create!(area: baltic_sea, neighbor: kiel, coastal: true)

    Border.create!(area: gulf_of_bothnia, neighbor: sweden, coastal: true)
    Border.create!(area: gulf_of_bothnia, neighbor: finland, coastal: true)
    Border.create!(area: gulf_of_bothnia, neighbor: saint_petersburg, coastal: true)
    Border.create!(area: gulf_of_bothnia, neighbor: saint_petersburg_sc, coastal: true)
    Border.create!(area: gulf_of_bothnia, neighbor: livonia, coastal: true)
    Border.create!(area: gulf_of_bothnia, neighbor: baltic_sea)

    Border.create!(area: barents_sea, neighbor: saint_petersburg, coastal: true)
    Border.create!(area: barents_sea, neighbor: saint_petersburg_nc, coastal: true)
    Border.create!(area: barents_sea, neighbor: norway, coastal: true)
    Border.create!(area: barents_sea, neighbor: norwegian_sea)

    Border.create!(area: western_mediterranean, neighbor: spain, coastal: true)
    Border.create!(area: western_mediterranean, neighbor: spain_sc, coastal: true)
    Border.create!(area: western_mediterranean, neighbor: gulf_of_lyons)
    Border.create!(area: western_mediterranean, neighbor: tyrrhenian_sea)
    Border.create!(area: western_mediterranean, neighbor: tunis, coastal: true)
    Border.create!(area: western_mediterranean, neighbor: north_africa, coastal: true)
    Border.create!(area: western_mediterranean, neighbor: mid_atlantic_ocean)

    Border.create!(area: gulf_of_lyons, neighbor: spain, coastal: true)
    Border.create!(area: gulf_of_lyons, neighbor: spain_sc, coastal: true)
    Border.create!(area: gulf_of_lyons, neighbor: marseilles, coastal: true)
    Border.create!(area: gulf_of_lyons, neighbor: piedmont, coastal: true)
    Border.create!(area: gulf_of_lyons, neighbor: tuscany, coastal: true)
    Border.create!(area: gulf_of_lyons, neighbor: tyrrhenian_sea)
    Border.create!(area: gulf_of_lyons, neighbor: western_mediterranean)

    Border.create!(area: tyrrhenian_sea, neighbor: western_mediterranean)
    Border.create!(area: tyrrhenian_sea, neighbor: gulf_of_lyons)
    Border.create!(area: tyrrhenian_sea, neighbor: tuscany, coastal: true)
    Border.create!(area: tyrrhenian_sea, neighbor: rome, coastal: true)
    Border.create!(area: tyrrhenian_sea, neighbor: naples, coastal: true)
    Border.create!(area: tyrrhenian_sea, neighbor: ionian_sea)
    Border.create!(area: tyrrhenian_sea, neighbor: tunis, coastal: true)

    Border.create!(area: ionian_sea, neighbor: tyrrhenian_sea)
    Border.create!(area: ionian_sea, neighbor: naples, coastal: true)
    Border.create!(area: ionian_sea, neighbor: apulia, coastal: true)
    Border.create!(area: ionian_sea, neighbor: adriatic_sea)
    Border.create!(area: ionian_sea, neighbor: albania, coastal: true)
    Border.create!(area: ionian_sea, neighbor: greece, coastal: true)
    Border.create!(area: ionian_sea, neighbor: aegean_sea)
    Border.create!(area: ionian_sea, neighbor: eastern_mediterranean)
    Border.create!(area: ionian_sea, neighbor: tunis, coastal: true)

    Border.create!(area: adriatic_sea, neighbor: trieste, coastal: true)
    Border.create!(area: adriatic_sea, neighbor: albania, coastal: true)
    Border.create!(area: adriatic_sea, neighbor: ionian_sea)
    Border.create!(area: adriatic_sea, neighbor: apulia, coastal: true)
    Border.create!(area: adriatic_sea, neighbor: venice, coastal: true)

    Border.create!(area: aegean_sea, neighbor: greece, coastal: true)
    Border.create!(area: aegean_sea, neighbor: bulgaria_sc, coastal: true)
    Border.create!(area: aegean_sea, neighbor: bulgaria, coastal: true)
    Border.create!(area: aegean_sea, neighbor: constantinople, coastal: true)
    Border.create!(area: aegean_sea, neighbor: smyrna, coastal: true)
    Border.create!(area: aegean_sea, neighbor: eastern_mediterranean)
    Border.create!(area: aegean_sea, neighbor: ionian_sea)

    Border.create!(area: eastern_mediterranean, neighbor: smyrna, coastal: true)
    Border.create!(area: eastern_mediterranean, neighbor: syria, coastal: true)
    Border.create!(area: eastern_mediterranean, neighbor: ionian_sea)
    Border.create!(area: eastern_mediterranean, neighbor: aegean_sea)

    Border.create!(area: black_sea, neighbor: sevastopol, coastal: true)
    Border.create!(area: black_sea, neighbor: armenia, coastal: true)
    Border.create!(area: black_sea, neighbor: ankara, coastal: true)
    Border.create!(area: black_sea, neighbor: constantinople, coastal: true)
    Border.create!(area: black_sea, neighbor: bulgaria, coastal: true)
    Border.create!(area: black_sea, neighbor: bulgaria_ec, coastal: true)
    Border.create!(area: black_sea, neighbor: rumania, coastal: true)
  end

  def self.teardown
    Border.destroy_all
    Coast.destroy_all
    Area.destroy_all
  end
end
