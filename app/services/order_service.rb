module OrderService
  def self.available_positions(positions)
    # output is of form { current_position: { order_type: [to, from?]} }
    result = {}
    positions.each do |position|
      if position.army?

      else
      end
    end
  end
end
