class StaticPagesController < ApplicationController
  def index
  end

  def demo
    @demo_indicators =  {""=>281, "I"=>2880, "L"=>949, "M"=>42, "P"=>39, "Q"=>144, "R"=>10, "S"=>236, "X"=>8}

    if params[:start] == nil && params[:finish] == nil
      @find_info = []
    else
      @find_info = Rbandit::Trdopt.where(id: params[:start]..params[:finish])
    end
  end

  def show
    @find_info = Rbandit::Trdopt.find(params[:search])
  end
end