require 'test_helper'

class OrderResolutionServiceTest < ActiveSupport::TestCase
  test "resolve-invalid_support" do
    turn = create(:turn)
    albania = Area.find_by_name('Albania')
    bulgaria = Area.find_by_name('Bulgaria')
    greece = Area.find_by_name('Greece')

    albania_position = create(:position, area: albania, type: 'army', turn: turn)

    order = create(:order, type: 'support', from: bulgaria, to: greece, position: albania_position, turn: turn)

    assert_equal([:invalid], OrderResolutionService.new(turn).resolve(order))
  end

  test "resolve-resolved_support" do
    turn = create(:turn)
    england = create(:user_game, power: 'england')
    germany = create(:user_game, power: 'germany')
    budapest = Area.find_by_name('Budapest')
    bulgaria = Area.find_by_name('Bulgaria')
    rumania = Area.find_by_name('Rumania')

    budapest_position = create(:position, area: budapest, type: 'army', user_game: england, turn: turn)
    bulgaria_position = create(:position, area: bulgaria, type: 'army', user_game: england, turn: turn)
    rumania_position = create(:position, area: rumania, type: 'army', user_game: germany, turn: turn)

    attack = create(:order, type: 'move', from: bulgaria, to: rumania, position: bulgaria_position, user_game: england, turn: turn)
    support = create(:order, type: 'support', from: bulgaria, to: rumania, position: budapest_position, user_game: england, turn: turn)
    dislodged = create(:order, type: 'move', from: rumania, to: budapest, position: rumania_position, user_game: germany, turn: turn)

    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(attack))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(support))
    assert_equal([:dislodged, attack], OrderResolutionService.new(turn).resolve(dislodged))
  end

  test "resolve-cut_support" do
    turn = create(:turn)
    budapest = Area.find_by_name('Budapest')
    bulgaria = Area.find_by_name('Bulgaria')
    rumania = Area.find_by_name('Rumania')
    serbia = Area.find_by_name('Serbia')

    budapest_position = create(:position, area: budapest, type: 'army', turn: turn)
    bulgaria_position = create(:position, area: bulgaria, type: 'army', turn: turn)
    serbia_position = create(:position, area: serbia, type: 'army', turn: turn)
    rumania_position = create(:position, area: rumania, type: 'army', turn: turn)

    attack = create(:order, type: 'move', from: bulgaria, to: rumania, position: bulgaria_position, turn: turn)
    cutter = create(:order, type: 'move', from: serbia, to: budapest, position: serbia_position, turn: turn)
    support = create(:order, type: 'support', from: bulgaria, to: rumania, position: budapest_position, turn: turn)
    hold = create(:order, type: 'hold', from: rumania, to: rumania, position: rumania_position, turn: turn)

    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(attack))
    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(cutter))
    assert_equal([:cut, cutter], OrderResolutionService.new(turn).resolve(support))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(hold))
  end

  test "resolve-move_swap" do
    turn = create(:turn)
    budapest = Area.find_by_name('Budapest')
    serbia = Area.find_by_name('Serbia')

    budapest_position = create(:position, area: budapest, type: 'army', turn: turn)
    serbia_position = create(:position, area: serbia, type: 'army', turn: turn)

    move1 = create(:order, type: 'move', from: budapest, to: serbia, position: budapest_position, turn: turn)
    move2 = create(:order, type: 'move', from: serbia, to: budapest, position: serbia_position, turn: turn)

    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(move1))
    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(move2))
  end

  test "resolve-supported_attack" do
    turn = create(:turn)
    england = create(:user_game, power: 'england')
    germany = create(:user_game, power: 'germany')
    budapest = Area.find_by_name('Budapest')
    bulgaria = Area.find_by_name('Bulgaria')
    rumania = Area.find_by_name('Rumania')

    budapest_position = create(:position, area: budapest, type: 'army', user_game: england, turn: turn)
    bulgaria_position = create(:position, area: bulgaria, type: 'army', user_game: england, turn: turn)
    rumania_position = create(:position, area: rumania, type: 'army', user_game: germany, turn: turn)

    attack = create(:order, type: 'move', from: bulgaria, to: rumania, position: bulgaria_position, user_game: england, turn: turn)
    support = create(:order, type: 'support', from: bulgaria, to: rumania, position: budapest_position, user_game: england, turn: turn)
    hold = create(:order, type: 'hold', from: rumania, to: rumania, position: rumania_position, user_game: germany, turn: turn)

    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(attack))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(support))
    assert_equal([:dislodged, attack], OrderResolutionService.new(turn).resolve(hold))
  end

  test "resolve-move_train" do
    turn = create(:turn)
    budapest = Area.find_by_name('Budapest')
    bulgaria = Area.find_by_name('Bulgaria')
    rumania = Area.find_by_name('Rumania')

    bulgaria_position = create(:position, area: bulgaria, type: 'army', turn: turn)
    rumania_position = create(:position, area: rumania, type: 'army', turn: turn)

    move1 = create(:order, type: 'move', from: bulgaria, to: rumania, position: bulgaria_position, turn: turn)
    move2 = create(:order, type: 'move', from: rumania, to: budapest, position: rumania_position, turn: turn)

    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move1))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move2))
  end

  test "resolve-power_cannot_dislodge_itself" do
    turn = create(:turn)
    user_game = create(:user_game)
    budapest = Area.find_by_name('Budapest')
    bulgaria = Area.find_by_name('Bulgaria')
    rumania = Area.find_by_name('Rumania')

    budapest_position = create(:position, area: budapest, type: 'army', user_game: user_game, turn: turn)
    bulgaria_position = create(:position, area: bulgaria, type: 'army', user_game: user_game, turn: turn)
    rumania_position = create(:position, area: rumania, type: 'army', user_game: user_game, turn: turn)

    attack = create(:order, type: 'move', from: bulgaria, to: rumania, position: bulgaria_position, user_game: user_game, turn: turn)
    support = create(:order, type: 'support', from: bulgaria, to: rumania, position: budapest_position, user_game: user_game, turn: turn)
    hold = create(:order, type: 'hold', from: rumania, to: rumania, position: rumania_position, user_game: user_game, turn: turn)

    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(attack))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(support))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(hold))
  end

  test "resolve-convoy" do
    turn = create(:turn)
    tunis = Area.find_by_name('Tunis')
    ionian_sea = Area.find_by_name('Ionian Sea')
    aegean_sea = Area.find_by_name('Aegean Sea')
    smyrna = Area.find_by_name('Smyrna')

    tunis_position = create(:position, area: tunis, type: 'army', turn: turn)
    ionian_sea_position = create(:position, area: ionian_sea, type: 'fleet', turn: turn)
    aegean_sea_position = create(:position, area: aegean_sea, type: 'fleet', turn: turn)

    move = create(:order, type: 'move', from: tunis, to: smyrna, position: tunis_position, turn: turn)
    convoy1 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: ionian_sea_position, turn: turn)
    convoy2 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: aegean_sea_position, turn: turn)

    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy1))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy2))
  end

  test "resolve-convoy_bounce" do
    turn = create(:turn)
    tunis = Area.find_by_name('Tunis')
    ionian_sea = Area.find_by_name('Ionian Sea')
    aegean_sea = Area.find_by_name('Aegean Sea')
    smyrna = Area.find_by_name('Smyrna')

    tunis_position = create(:position, area: tunis, type: 'army', turn: turn)
    ionian_sea_position = create(:position, area: ionian_sea, type: 'fleet', turn: turn)
    aegean_sea_position = create(:position, area: aegean_sea, type: 'fleet', turn: turn)
    smyrna_position = create(:position, area: smyrna, type: 'fleet', turn: turn)

    move = create(:order, type: 'move', from: tunis, to: smyrna, position: tunis_position, turn: turn)
    convoy1 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: ionian_sea_position, turn: turn)
    convoy2 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: aegean_sea_position, turn: turn)
    hold = create(:order, type: 'hold', from: smyrna, to: smyrna, position: smyrna_position, turn: turn)

    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(move))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy1))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(convoy2))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(hold))
  end

  test "resolve-convoy_disrupted" do
    turn = create(:turn)
    england = create(:user_game, power: 'england')
    germany = create(:user_game, power: 'germany')
    tunis = Area.find_by_name('Tunis')
    ionian_sea = Area.find_by_name('Ionian Sea')
    aegean_sea = Area.find_by_name('Aegean Sea')
    smyrna = Area.find_by_name('Smyrna')
    adriatic_sea = Area.find_by_name('Adriatic Sea')
    tyrrhenian_sea = Area.find_by_name('Tyrrhenian Sea')

    tunis_position = create(:position, area: tunis, type: 'army', user_game: england, turn: turn)
    ionian_sea_position = create(:position, area: ionian_sea, type: 'fleet', user_game: england, turn: turn)
    aegean_sea_position = create(:position, area: aegean_sea, type: 'fleet', user_game: england, turn: turn)
    adriatic_sea_position = create(:position, area: adriatic_sea, type: 'fleet', user_game: germany, turn: turn)
    tyrrhenian_sea_position = create(:position, area: tyrrhenian_sea, type: 'fleet', user_game: germany, turn: turn)

    move = create(:order, type: 'move', from: tunis, to: smyrna, position: tunis_position, user_game: england, turn: turn)
    convoy1 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: ionian_sea_position, user_game: england, turn: turn)
    convoy2 = create(:order, type: 'convoy', from: tunis, to: smyrna, position: aegean_sea_position, user_game: england, turn: turn)
    attack_convoy = create(:order, type: 'move', from: adriatic_sea, to: ionian_sea, position: adriatic_sea_position, user_game: germany, turn: turn)
    support_attack = create(:order, type: 'support', from: adriatic_sea, to: ionian_sea, position: tyrrhenian_sea_position, user_game: germany, turn: turn)

    assert_equal([:cancelled], OrderResolutionService.new(turn).resolve(move))
    assert_equal([:dislodged, attack_convoy], OrderResolutionService.new(turn).resolve(convoy1))
    assert_equal([:cancelled], OrderResolutionService.new(turn).resolve(convoy2))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(attack_convoy))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(support_attack))
  end

  test "resolve-broken_attack" do
    turn = create(:turn)
    budapest = Area.find_by_name('Budapest')
    galicia = Area.find_by_name('Galicia')
    greece = Area.find_by_name('Greece')
    serbia = Area.find_by_name('Serbia')
    vienna = Area.find_by_name('Vienna')

    galicia_position = create(:position, area: galicia, type: 'army', turn: turn)
    greece_position = create(:position, area: greece, type: 'army', turn: turn)
    serbia_position = create(:position, area: serbia, type: 'army', turn: turn)
    vienna_position = create(:position, area: vienna, type: 'army', turn: turn)

    move1 = create(:order, type: 'move', from: greece, to: serbia, position: greece_position, turn: turn)
    move2 = create(:order, type: 'move', from: serbia, to: budapest, position: serbia_position, turn: turn)
    move3 = create(:order, type: 'move', from: vienna, to: budapest, position: vienna_position, turn: turn)
    support = create(:order, type: 'support', from: vienna, to: budapest, position: galicia_position, turn: turn)

    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(move1))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move3))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(support))
    assert_equal([:broken, move3], OrderResolutionService.new(turn).resolve(move2))
  end

  test "resolve_three_way_swap" do
    turn = create(:turn)
    budapest = Area.find_by_name('Budapest')
    galicia = Area.find_by_name('Galicia')
    vienna = Area.find_by_name('Vienna')

    budapest_position = create(:position, area: budapest, type: 'army', turn: turn)
    galicia_position = create(:position, area: galicia, type: 'army', turn: turn)
    vienna_position = create(:position, area: vienna, type: 'army', turn: turn)

    move1 = create(:order, type: 'move', from: budapest, to: galicia, position: budapest_position, turn: turn)
    move2 = create(:order, type: 'move', from: galicia, to: vienna, position: galicia_position, turn: turn)
    move3 = create(:order, type: 'move', from: vienna, to: budapest, position: vienna_position, turn: turn)

    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move1))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move2))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(move3))
  end

  test "resolve_bounce_train" do
    turn = create(:turn)
    turkey = create(:user_game, power: 'turkey')
    austria = create(:user_game, power: 'austria')
    greece = Area.find_by_name('Greece')
    bulgaria = Area.find_by_name('Bulgaria')
    constantinople = Area.find_by_name('Constantinople')
    smyrna = Area.find_by_name('Smyrna')

    greece_position = create(:position, area: greece, type: 'army', turn: turn, user_game: austria)
    bulgaria_position = create(:position, area: bulgaria, type: 'army', turn: turn, user_game: turkey)
    constantinople_position = create(:position, area: constantinople, type: 'army', turn: turn, user_game: turkey)
    smyrna_position = create(:position, area: smyrna, type: 'army', turn: turn, user_game: turkey)

    hold = create(:order, type: 'hold', from: greece, to: greece, position: greece_position, turn: turn, user_game: austria)
    move1 = create(:order, type: 'move', from: bulgaria, to: greece, position: bulgaria_position, turn: turn, user_game: turkey)
    move2 = create(:order, type: 'move', from: constantinople, to: bulgaria, position: constantinople_position, turn: turn, user_game: turkey)
    move3 = create(:order, type: 'move', from: smyrna, to: constantinople, position: smyrna_position, turn: turn, user_game: turkey)

    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(hold))
    assert_equal([:broken, move1], OrderResolutionService.new(turn).resolve(move1))
    assert_equal([:broken, move2], OrderResolutionService.new(turn).resolve(move2))
    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(move3))
  end

  test "resolve_support_supporting_unit" do
    turn = create(:turn)
    turkey = create(:user_game, power: 'turkey')
    austria = create(:user_game, power: 'austria')
    greece = Area.find_by_name('Greece')
    bulgaria = Area.find_by_name('Bulgaria')
    constantinople = Area.find_by_name('Constantinople')

    greece_position = create(:position, area: greece, type: 'army', turn: turn, user_game: austria)
    bulgaria_position = create(:position, area: bulgaria, type: 'army', turn: turn, user_game: turkey)
    constantinople_position = create(:position, area: constantinople, type: 'army', turn: turn, user_game: turkey)

    move = create(:order, type: 'move', from: greece, to: bulgaria, position: greece_position, turn: turn, user_game: austria)
    support1 = create(:order, type: 'support', from: constantinople, to: constantinople, position: bulgaria_position, turn: turn, user_game: turkey)
    support2 = create(:order, type: 'support', from: bulgaria, to: bulgaria, position: constantinople_position, turn: turn, user_game: turkey)

    assert_equal([:bounced], OrderResolutionService.new(turn).resolve(move))
    assert_equal([:cut, move], OrderResolutionService.new(turn).resolve(support1))
    assert_equal([:resolved], OrderResolutionService.new(turn).resolve(support2))
  end
end
