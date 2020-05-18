module PathService
  def self.fleet_accessible(area)
    AreaService.neighboring_areas_map[area].select do |a|
      a.sea? || (a.land? && area.borders.where(neighbor: a, coastal: true).present?)
    end
  end

  def self.supportable_areas(position)
    if position.fleet?
      fleet_possible_paths(position).map { |path| path.last.first }
    else
      AreaService.neighboring_areas_map[position.area].select { |a| a.land? }
    end
  end

  def self.possible_paths(position, other_unit_positions)
    if position.fleet?
      fleet_possible_paths(position)
    else
      army_possible_paths(position, other_unit_positions, [position.area])
    end.reject do |path|
      path.first == path.last
    end
  end

  def self.fleet_possible_paths(position)
    paths = []
    fleet_accessible(AreaService.area_map[position.area_id]).reject do |area|
      position.coast_id.present? && !AreaService.neighboring_coasts_map[area].include?(position.coast)
    end.map do |destination|
      from = [position.area, position.coast]
      if destination.coasts?
        destination.coasts.select { |c| AreaService.neighboring_coasts_map[position.area].include?(c) }.each do |coast|
          paths << [from, [destination, coast]]
        end
      else
        paths << [from, [destination, nil]]
      end
    end
    paths
  end

  # Returns paths that an army can move to directly or via convoy
  def self.army_possible_paths(current_position, remaining_positions, current_path, paths=[])
    AreaService.neighboring_areas_map[AreaService.area_map[current_position.area_id]].each do |neighboring_area|
      paths << [*current_path, neighboring_area] if neighboring_area.land?

      convoy_position = remaining_positions.find do |position|
        position.fleet? && AreaService.area_map[position.area_id].sea? && position.area_id == neighboring_area.id
      end

      if convoy_position.present?
        army_possible_paths(
          convoy_position,
          remaining_positions.without(current_position, convoy_position),
          [*current_path, neighboring_area],
          paths,
        )
      end
    end
    paths
  end

  def self.requires_convoy?(from, to)
    # TODO: does not handle convoying to adjacent coast
    !AreaService.neighboring_areas_map[from].include?(to)
  end
end
