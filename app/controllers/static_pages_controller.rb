class StaticPagesController < ApplicationController
  before_filter :req_psetter, :except=>[:home,:info]
  
  def admin
    if session[:user_id]
      @user = User.find(session[:user_id])
    end
  end

end
