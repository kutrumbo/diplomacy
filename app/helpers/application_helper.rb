module ApplicationHelper
  def format_order_resolution(order, resolution)
    unit_type = order.position.type&.humanize
    loc = format_location_name(order.position.area, order.position.coast)
    res = resolution.to_s.humanize
    from_loc = format_location_name(order.from, order.from_coast)
    to_loc = format_location_name(order.to, order.to_coast)
    order_description = case order.type
    when 'hold'
      "#{unit_type} #{loc} hold - #{res}"
    when 'build_fleet'
      "Build fleet in #{to_loc}"
    when 'build_army'
      "Build army in #{loc}"
    when 'move'
      "#{unit_type} #{loc} move to #{to_loc} - #{res}"
    when 'support'
      "#{unit_type} #{loc} support #{from_loc} to #{to_loc} - #{res}"
    when 'convoy'
      "#{unit_type} #{loc} convoy #{from_loc} to #{to_loc} - #{res}"
    when 'retreat'
      "#{unit_type} #{loc} retreat to #{to_loc} - #{res}"
    when 'disband'
      "#{unit_type} #{loc} disbanded"
    when 'no_build', 'keep'
      nil
    else
      raise 'Unsupported order type'
    end
    order_description
  end

  def format_location_name(area, coast)
    return nil unless area.present?
    if coast.present?
      "#{area.name} (#{coast.direction.first.upcase}C)"
    else
      area.name
    end
  end
end
