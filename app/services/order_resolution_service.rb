class OrderResolutionService
  def initialize(turn)
    raise 'Aleady resolved' if turn.resolutions.any?
    @turn = turn
    @orders = @turn.orders
    @orders_by_id = @orders.group_by(&:id) # {id: :order}
    # {order: :position}
    @order_position_map = turn.positions.includes(:order).reduce({}) do |map, position|
      map[position.order] = position
      map
    end
    # {order: :resolution}
    @order_resolutions = Hash[@orders.collect { |order| [order, Resolution.new(order: order)] } ]
    @to_map = @orders.group_by(&:to_id) # {to_id: [:orders]}
    @move_tree = @orders.move.group_by(&:to_id)
    @corresponding_map = {} # {support_or_convoy_order: :corresponding_order}
    @supporting_orders = {} # {order: [:supporting_orders]}
    @convoying_orders = {} # {order: [:convoying_orders]}
  end

  def resolve_orders
    if @turn.attack?
      initial_convoy_resolve
      construct_incidence_matrix
      initial_support_resolve
      initial_move_resolve
      dislodge_resolve
    elsif @turn.retreat?
      retreat_resolve
    elsif @turn.build?
      @turn.orders.each { |order| @order_resolutions[order].status = 'resolved' }
    end

    raise 'Not all orders resolved' if @order_resolutions.values.any? { |r| r.status.nil? }

    @order_resolutions.values.map(&:save!)
    @order_resolutions
  end

  private

  def initial_convoy_resolve
    convoy_moves = @orders.move.select do |o|
      PathService.requires_convoy?(AreaService.area_map[o.from_id], AreaService.area_map[o.to_id])
    end

    convoy_orders = @orders.convoy.to_a
    convoy_moves.each do |order|
      corresponding_convoy_orders = convoy_orders.select do |o|
        o.from_id == order.from_id && o.to_id == order.to_id
      end
      if corresponding_convoy_orders.empty?
        @order_resolutions[order].status = 'invalid'
      else
        corresponding_convoy_orders.each do |o|
          @corresponding_map[o] = order
          @order_resolutions[o].status = 'resolved'
        end
        @convoying_orders[order] = corresponding_convoy_orders
        convoy_orders -= corresponding_convoy_orders
      end
    end
    convoy_orders.each do |order|
      @order_resolutions[order].status = 'invalid'
    end
  end

  def construct_incidence_matrix
    @move_area_ids = @orders.move.reject do |order|
      # do not include move orders that failed due to invalid convoy
      @order_resolutions[order].status.present?
    end.pluck(:to_id, :from_id).flatten.uniq.sort
    @incidence_matrix = Array.new(@move_area_ids.size) { Array.new(@move_area_ids.size, 0) }
    @orders.move.each do |order|
      from_index = @move_area_ids.index(order.from_id)
      to_index = @move_area_ids.index(order.to_id)
      @incidence_matrix[from_index][to_index] = -1
      @incidence_matrix[to_index][from_index] = 1
    end
    # print_incidence_matrix
  end

  # inspect the incident_matrix to separate out disconnected graphs to be resolved separately
  def parse_disconnected_graphs
    node_ids = @move_area_ids.dup
    graphs = []
    while node_ids.present?
      graph = []
      traverse_node(node_ids.first, graph, node_ids)
      graphs << graph
    end
    order_graphs_via_convoy_dependency(graphs)
  end

  def traverse_node(node, graph, node_ids)
    graph.push(node_ids.delete(node))
    node_index = @move_area_ids.index(node)
    @incidence_matrix[node_index].each_with_index do |value, index|
      next_node = @move_area_ids[index]
      traverse_node(next_node, graph, node_ids) if value != 0 && node_ids.include?(next_node)
    end
  end

  def initial_support_resolve
    @orders.support.includes(position: :area).each do |order|
      # TODO: move shouldn't count if it is not convoyed properly
      @corresponding_map[order] = @orders.includes(:position).without(order).find do |o|
        (o.move? && o.from_id == order.from_id && o.to_id == order.to_id) ||
          (!o.move? && order.from_id == order.to_id && order.to_id == o.position.area_id)
      end

      if @corresponding_map[order].nil?
        @order_resolutions[order].status = 'invalid'
        next
      else
      end

      cut = @to_map[order.position.area_id]&.any? do |o|
        o.move? && o.user_game_id != order.user_game_id && o.from_id != order.to_id
      end
      @order_resolutions[order].status = cut ? 'cut' : 'resolved'
      (@supporting_orders[@corresponding_map[order]] ||= []).push(order) if @order_resolutions[order].resolved?
    end
  end

  # sort the graphs such that graphs attacking the convoy of another graph are resolved first
  def order_graphs_via_convoy_dependency(graphs)
    graphs_with_convoys = graphs.map do |graph|
      convoys = @convoying_orders.select do |move_order, _|
        graph.include?(move_order.to_id) && graph.include?(move_order.from_id)
      end.values.flatten
      [graph, convoys.map { |o| @order_position_map[o].area_id }]
    end
    graphs_with_convoys.sort do |a, b|
      a_attacks_b_convoys = a.first.any? { |aid| b.second.include?(aid) }
      b_attacks_a_convoys = b.first.any? { |aid| a.second.include?(aid) }

      if a_attacks_b_convoys && b_attacks_a_convoys
        # TODO: handle paradox
        raise 'Circular convoy paradox'
      end

      if a_attacks_b_convoys
        -1
      elsif b_attacks_a_convoys
        1
      else
        0
      end
    end.map(&:first)
  end

  def initial_move_resolve
    valid_move_orders = @orders.move.reject { |o| @order_resolutions[o].status.present? }
    parse_disconnected_graphs.each do |graph|
      sink_id = graph.find do |area_id|
        index = @move_area_ids.index(area_id)
        # if no nodes are positive, that index corresponds to a sink
        @incidence_matrix[index].count(-1) == 0
      end
      if sink_id.present?
        sink_orders = valid_move_orders.select { |o| o.to_id == sink_id }
        resolve_tree_graph(sink_orders)
      else
        loop_orders = valid_move_orders.select { |o| graph.include?(o.from_id) || graph.include?(o.to_id) }
        resolve_loop_graph(loop_orders)
      end
    end
  end

  # if moves are in a loop, check for a bounce in the loop to use as the sink to force proper bounce backs
  def resolve_loop_graph(orders)
    bounce = orders.find do |order|
      resolve_move(order, true)
    end
    if bounce.nil?
      # mark all moves as resolved
      orders.each do |order|
        @order_resolutions[order].status = 'resolved'
      end
    else
      resolve_tree_graph([bounce])
    end
  end

  # if moves are in a tree, start at the sink and work iteratively through children
  def resolve_tree_graph(sink_orders)
    orders = sink_orders
    while orders.present?
      orders.each { |order| resolve_move(order) }
      orders = orders.map do |order|
        @move_tree[order.from_id]
      end.flatten.compact.uniq.reject do |order|
        @order_resolutions[order]&.status.present?
      end
    end
  end

  def resolve_move(order, check_bounce=false)
    # quick return if already resolved (for instance due to invalid convoy)
    return if @order_resolutions[order].status.present?
    # if convoy order, fail if convoying fleet is dislodged
    if @convoying_orders[order].present?
      # TODO: handle multiple convoys
      # this depends on move orders that are attacking the convoying orders to have been resolved
      convoy_dislodged = @convoying_orders[order].any? do |convoying_order|
        successful_move_orders = @order_resolutions.select do |o, resolution|
          o.move? && resolution.resolved?
        end.keys
        successful_move_orders.any? { |o| o.to_id == @order_position_map[convoying_order].area_id }
      end
      if convoy_dislodged
        @order_resolutions[order].status = 'failed'
        return
      end
    end
    support_map = calculate_support_map(order.to_id, check_bounce)

    support_strengths = support_map.values.map(&:size)
    max_strength = support_strengths.max
    move_strength = support_map[order].size
    bounce = support_strengths.count { |i| i == max_strength } > 1

    return bounce if check_bounce

    @order_resolutions[order].status = if move_strength == max_strength && !bounce
      origin_order = support_map.keys.find do |o|
        @order_position_map[o].area_id == order.to_id
      end
      if origin_order&.user_game_id == order.user_game_id
        # cannot dislodged own units
        'bounced'
      else
        'resolved'
      end
    else
      # TODO: support two units swapping via convoy
      'bounced'
    end
  end

  def dislodge_resolve
    @orders.includes(position: :area).each do |order|
      next if order.move? && @order_resolutions[order].resolved?

      dislodged = @to_map[order.position.area_id]&.any? do |o|
        o.move? && @order_resolutions[o].resolved?
      end
      if dislodged
        @order_resolutions[order].status = 'dislodged'
      else
        @order_resolutions[order].status = 'resolved' if order.hold?
      end
    end
  end


  def supporting_orders(order)
    @supporting_orders[order] || []
  end

  def calculate_support_map(area_id, check_bounce=false)
    support_map = {}
    # TODO: N+1
    origin_order = @orders.joins(:position).where(positions: { area_id: area_id }).first
    if origin_order.present? && !(origin_order.move? && (@order_resolutions[origin_order].resolved? || check_bounce))
      # resolved moves do not count towards area defense
      support_map[origin_order] = origin_order.move? ? [] : supporting_orders(origin_order)
    end
    # TODO: N+1
    @orders.where(type: 'move', to_id: area_id).each do |order|
      support_map[order] = supporting_orders(order)
    end
    support_map
  end

  def print_incidence_matrix
    puts '*******************************************************'
    puts ''
    puts @move_area_ids.map { |aid| Area.find(aid).name }.join(' ')
    puts ''
    @incidence_matrix.each do |row|
      puts row.join(' ')
    end
    puts ''
    puts '*******************************************************'
  end

  def retreat_resolve
    conflicting_retreats = @turn.orders.retreat.group_by(&:to_id).select do |_, orders|
      orders.size > 1
    end.values.flatten
    @order_resolutions.each do |order, resolution|
      resolution.status = conflicting_retreats.include?(order) ? 'failed' : 'resolved'
    end
  end
end
