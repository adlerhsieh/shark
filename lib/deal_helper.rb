module DealHelper

  def buy?
    direction == "buy"
  end
  alias long? buy?

  def sell?
    direction == "sell"
  end
  alias short? sell?

  def opened?
    opened_at.present? && closed_at.blank?
  end

  def closed?
    closed_at.present?
  end

  def pending?
    opened_at.blank? && closed_at.blank?
  end

end
