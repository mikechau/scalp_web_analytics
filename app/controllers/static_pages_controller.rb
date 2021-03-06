class StaticPagesController < ApplicationController
  def index
  end

  def demo_index
  end

  def demo3
    if params[:start_date] && params[:end_date] && params[:group_type] != ''

      @results = Data::Indicator.new({ :start_date => params[:start_date], :end_date => params[:end_date], :group_type => params[:group_type] })
      @results.execute

      @json_results = @results.table

      @results.table = Kaminari.paginate_array(@results.table).page(params[:page]).per(20)

      @results_cats = @results.table[0..5].map { |r| r[0] }
      @results_dats = @results.table[0..5].map { |r| r[1] }

      respond_to do |format|
        format.html
        format.json { render json: @json_results }
      end

    else
      redirect_to demo_index_url
    end

  end

  def demo4

    if params[:start_date] && params[:end_date] != nil
      @results = Rbandit::Trdopt.joins(:instropt).where(:ts => params[:start_date]..params[:end_date]).group('instropt.underlying').select('instropt.underlying, COUNT(*) as cnt')
      @results.map! { |r| [r.underlying, r.cnt] }
      @results = @results.sort_by &:last
      @results.reverse!

      @results = Kaminari.paginate_array(@results).page(params[:page]).per(20)

      @results_cats = @results[0..20].map { |r| r[0] }
      @results_dats = @results[0..20].map { |r| r[1] }

    else
      @results = nil
    end
  end

  def demo5
    @results = Rbandit::Instropt.joins(:trdopts).where("expiration >= ? AND underlying = ? AND trdopt.ts >= ? AND trdopt.ts <= ?", Date.today, params[:underlying], "2013-05-21 9:30:00", "2013-05-21 10:00:00").count
  end

end


 # a = Rbandit::Instropt.joins(:trdopts).where("expiration >= ? AND underlying = ? AND trdopt.ts >= ? AND trdopt.ts <= ?", Date.today, "SNE", "2013-05-21 9:30:00", "2013-05-21 23:59:59").count
