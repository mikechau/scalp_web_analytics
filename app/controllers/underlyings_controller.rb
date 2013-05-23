class UnderlyingsController < ApplicationController

  def index
  end

  def search_underlying_name
    puts params[:underlying_name]
    u_names = Rbandit::Instropt.where("underlying LIKE :name", name: "#{params[:underlying_name]}%").uniq.pluck(:underlying)
    u_names.sort!
    render json: u_names[0..4]
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

  def top_indicators
    @top = Rbandit::Trdopt.top_indicators(params[:start_date], params[:end_date], params[:underlying_name])
    @results = Kaminari.paginate_array(@top).page(params[:page]).per(20)

    @results_cats = @results[0..5].map { |r| r[0] }
    @results_dats = @results[0..5].map { |r| r[1] }

    respond_to do |format|
      format.html
      format.json { render json: @top }
    end
  end

  def top_volume
    @top = Rbandit::Trdstatsopt.top_volume(params[:start_date], params[:end_date], params[:underlying_name], params[:limit_amt])
    @results = Kaminari.paginate_array(@top).page(params[:page]).per(20)

    @results_cats = @results[0..9].map { |r| "[#{r[:underlying]}] - #{r[:expiration]} - #{r[:strike]}, #{r[:option]}" }
    @results_dats = @results[0..9].map { |r| r[:volume] }

    respond_to do |format|
      format.html
      format.json { render json: @top }
    end
  end

  def top_size
    @top = Rbandit::Trdopt.top_size(params[:start_date], params[:end_date], params[:underlying_name], params[:limit_amt])
    @results = Kaminari.paginate_array(@top).page(params[:page]).per(20)

    @results_cats = @results[0..9].map { |r| "[#{r[:underlying]}] - #{r[:expiration]} - #{r[:strike]}, #{r[:option]}" }
    @results_dats = @results[0..9].map { |r| r[:size] }

    respond_to do |format|
      format.html
      format.json { render json: @top }
    end
  end

end