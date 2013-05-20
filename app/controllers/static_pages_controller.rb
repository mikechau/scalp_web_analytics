class StaticPagesController < ApplicationController
  def index
  end

  def demo_index
  end

  def demo3
    @indicator_names = Rbandit::Trdindopt.all
    if params[:start_date] && params[:end_date] && params[:group_type] != ''
      case params[:group_type]
      when "ind" 
        @indicators = Data::Indicator.new(params[:start_date], params[:end_date], @indicator_names)
        @indicators.execute
      end
      
      respond_to do |format|
        format.html
        format.json { render json: @indicators }
      end

    else
      redirect_to demo_index_url
    end

  end

end