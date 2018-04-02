Order.all.each do |order|
  if order.signal_id
    fx_signal = FxSignal.find_by(id: order.signal_id)
    order.fx_signals << fx_signal if fx_signal
  end
end

Position.all.each do |position|
  if position.signal_id
    fx_signal = FxSignal.find_by(id: position.signal_id)
    position.fx_signals << fx_signal if fx_signal
  end
end
