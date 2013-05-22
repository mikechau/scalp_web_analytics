class UnderlyingsController < ApplicationController

  def index
  end

  def search_underlying_name
    puts params[:underlying_name]
    u_names = Rbandit::Instropt.where("underlying LIKE :name", name: "#{params[:underlying_name]}%").uniq.pluck(:underlying)
    u_names.sort!
    render json: u_names[0..7]
  end

  def top
    @top = Rbandit::Trdopt.top_underlying(params[:start_date], params[:end_date])
    @results = Kaminari.paginate_array(@top).page(params[:page]).per(20)

    @results_cats = @results[0..20].map { |r| r[0] }
    @results_dats = @results[0..20].map { |r| r[1] }

    respond_to do |format|
      format.html
      format.json { render json: @top }
    end
  end

end