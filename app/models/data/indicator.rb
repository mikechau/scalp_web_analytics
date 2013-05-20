class Data::Indicator

  attr_reader :cats, :dats
  attr_accessor :table

  def initialize(start_date, end_date, group_type)
    @start_date = start_date
    @end_date = end_date
    @group_type = group_type
    @trd_count = []
    @trd_names = []
    #@ind_array = []
    @table = []
    @cats = []
    @dats = []
  end

  def execute
    clean_count(get_count)
    get_names(@group_type)
    build_cats_data(@trd_count)
    build_table(@cats, @dats)
  end

  def clean_count(trd_count)
    sorted = sort_count(trd_count)
    reversed = reverse_count(sorted)
    save_count(reversed)
  end

  def get_count
    @trd_count = Rbandit::Trdopt.where(:ts => @start_date..@end_date).count(group: @group_type)
  end

  def sort_count(trd_count)
    trd_count.sort_by &:last
  end

  def reverse_count(trd_count)
    trd_count.reverse! 
  end

  def save_count(trd_count)
    @trd_count = trd_count
  end

  def get_names(group_type)
    case group_type
    when 'ind'
      @trd_names = Rbandit::Trdindopt.all
    when 'exchcode'
      @trd_names = Rbandit::Exchopt.all
    else
      @trd_names = nil
    end
  end

  def build_cats_data(trd_count)
    @cats = build_categories(trd_count)
    @dats = build_data(trd_count)
    #build_data_array(@ind_dats)
  end

  def build_categories(trd_count)
    if @trd_names != nil
      trd_count.map { |i| @trd_names.find { |n| n.id == i[0] }.name }
    else
      trd_count.map { |i| i[0] }
    end
  end

  def build_data(trd_count)
    trd_count.map { |i| i[1] }
  end

  # def build_data_array(data)
  #   data.each do |d|
  #     hash = {}
  #     hash["name"] = "Indicator"
  #     hash["data"] = [d]
  #     @ind_array << hash
  #   end
  # end

  def build_table(cats, data)
    @table = cats.zip(data)
  end
end