class Admin::BaseController < ApplicationController
  http_basic_authenticate_with name: "johnny", password: "funny$"
end
