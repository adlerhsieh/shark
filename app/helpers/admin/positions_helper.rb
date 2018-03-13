module Admin::PositionsHelper

  def position_class(position)
    if position.profit?
      "profit"
    elsif position.loss?
      "loss"
    end
  end

  def pl(position)
    (position.pl.positive? ? "+" : "-") + "$" + position.pl.abs.to_s
  end

end
