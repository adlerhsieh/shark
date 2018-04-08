class SourcesTradingStrategy < ApplicationRecord

  belongs_to :trading_strategy
  belongs_to :source

  alias strategy trading_strategy 

  delegate :name, :description, to: :trading_strategy

  def create_order_from(signal, options = {})
    attrs = signal.attributes.symbolize_keys.slice(
      *%i[
        pair_id direction entry take_profit stop_loss source_id
        expired_at terminated_at
      ]
    ).merge!(
      size: options[:size] || 1,
      trading_strategy_id: trading_strategy_id
    )

    order = case name
            when :multi_level_tp, :constant
              Order.create!(attrs)
            when :minimize_tp_sl
            end

    order.tap { |o| o.signals << signal }
  end

  def create_ig_order_from(signal)
    create_order_from(signal).tap { |order| order.ig_place_order }
  end

end
