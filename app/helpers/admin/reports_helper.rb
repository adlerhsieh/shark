module Admin::ReportsHelper

  def pl_class(pl)
    pl.positive? ? "table-success" : "table-danger"
  end

end
