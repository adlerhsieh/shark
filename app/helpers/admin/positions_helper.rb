module Admin::PositionsHelper

  def position_class(position)
    if position.profit?
      "profit"
    elsif position.loss?
      "loss"
    end
  end

end
