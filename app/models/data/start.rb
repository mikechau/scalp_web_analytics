class Data::Start
  attr_reader :indicators

  def initiatilize
    @indicators = []
  end

  def self.building_data(start_date, end_date, group_type, ind_names)
    case group_type
      when "ind"
        @indicators = Data::Start.new
        @indicators = Data::Indicator.new(start_date, end_date, ind_names)
        @indicators.execute
    end
  end
end