class UnderlyingsController < ApplicationController

  def index
  end

  def search_underlying_name
    puts params[:underlying_name]
    u_names = Rbandit::Instropt.where("underlying LIKE :name", name: "#{params[:underlying_name]}%").uniq.pluck(:underlying)
    u_names.sort!
    render json: u_names[0..7]
  end

end