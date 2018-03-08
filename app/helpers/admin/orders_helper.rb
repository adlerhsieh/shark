module Admin::OrdersHelper
  def order_result_class(order)
    if order.closed?
      if order.position.profit?
        "profit"
      else
        "loss"
      end
    elsif order.expired?
      "expired"
    end
  end

end
