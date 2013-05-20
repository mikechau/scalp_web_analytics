class StaticPagesController < ApplicationController
  def index
  end

  def demo
    @demo_indicators =  {""=>281, "I"=>2880, "L"=>949, "M"=>42, "P"=>39, "Q"=>144, "R"=>10, "S"=>236, "X"=>8}

    if params[:start] == nil && params[:finish] == nil
      @find_info = Rbandit::Trdopt.where(:id => 42744147..42744150).page(params[:page])
    else
      @find_info = Rbandit::Trdopt.where(params[:search].to_s => params[:start]..params[:finish]).page(params[:page])
      @chart_info = Rbandit::Trdopt.where(id: params[:start]..params[:finish]).count(group: params[:filter_type])
    end
  end

  def demo2
    @find_info = Rbandit::Trdopt.where(params[:search].to_s => params[:start]..params[:finish]).page(params[:page])
    @chart_info = Rbandit::Trdopt.where(id: params[:start]..params[:finish]).count(group: params[:filter_type])
  end

  def demo_index
    
  end

  def demo3
    @indicator_names = Rbandit::Trdindopt.all
    if params[:start_date] && params[:end_date] && params[:group_type] != ''
      @indicators = Data::Indicator.new(params[:start_date], params[:end_date], @indicator_names)
      @indicators.execute

      respond_to do |format|
        format.html
        format.json { render json: @indicators }
      end

    else
      redirect_to demo_index_url
    end

  end

end