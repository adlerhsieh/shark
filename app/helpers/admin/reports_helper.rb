module Admin::ReportsHelper

  def pl_class(pl)
    return if pl.blank? || pl.zero?
    pl.positive? ? "table-success" : "table-danger"
  end

end
