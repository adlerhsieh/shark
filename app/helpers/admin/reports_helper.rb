module Admin::ReportsHelper

  def pl_class(pl)
    return if pl.blank? || pl.zero?
    pl.positive? ? "table-success" : "table-danger"
  end

  def ongoing_positions_from(source, date)
    positions_from(source, date).try(:select) {|p| p.opened_at && p.closed_at.nil? }
  end

  def positions_from(source, date)
    source.positions_by_date[date.to_s(:date)] 
  end

  def signals_from(source, date)
    source.signals_by_date[date.to_s(:date)]
  end

  def pl_from(source, date)
    source.positions_by_date[date.to_s(:date)].try(:map) {|p| p.pl }.try(:compact).try(:sum) || 0
  end

  def no_source_data?(source, date)
    signals_from(source, date).blank? && positions_from(source, date).blank?
  end

  def no_source_data_at_all?(source)
    source.signals_by_date.all? {|_, v| v.blank? } &&
      source.positions_by_date.all? {|_, v| v.blank? }
  end

end
