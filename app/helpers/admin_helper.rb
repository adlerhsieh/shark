module AdminHelper
  
  def issue_flag_class(deal)
    "table-warning" if deal.issue?
  end

end
