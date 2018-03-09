class Admin::BaseController < ApplicationController
  before_action :authenticate_admin
  before_action :push_admin_to_gon

  def authenticate_admin
    redirect_to "/users/sign_in" unless admin?
  end

  def push_admin_to_gon
    gon.push(
      admin: true
    )
  end

  def admin?
    current_user.present? && current_user.admin?
  end

end
