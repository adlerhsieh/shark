class Admin::BaseController < ApplicationController
  before_action :authenticate_admin

  def authenticate_admin
    if current_user.nil? || current_user.admin?.!
      redirect_to "/users/sign_in"
    end
  end

end
