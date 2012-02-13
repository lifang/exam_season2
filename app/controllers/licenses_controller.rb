# encoding: utf-8
class LicensesController < ApplicationController
  before_filter :access?
  def index
    @invite_codes = InviteCode.search(nil, params[:page])
  end

  def search
    @invite_codes = InviteCode.search(params[:code].strip, params[:page])
    render "index"
  end

end
