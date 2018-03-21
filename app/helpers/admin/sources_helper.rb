module Admin::SourcesHelper

  def back_to_source_link
    return if params[:source_id].blank?

    link_to "Back to Source", 
      admin_source_path(id: params[:source_id]), 
      class: "btn btn-light btn-wide", 
      style: "margin-bottom: 10px; margin-top: 5px;"
  end

  def profit_rate(positions)
    (positions.select { |position| position.profit? }.size.to_f / positions.size) * 100
  end

end
