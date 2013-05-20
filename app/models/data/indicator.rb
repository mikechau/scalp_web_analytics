class Data::Indicator

  attr_reader :ind_cats, :ind_dats, :table

  def initialize(start_date, end_date, ind_names)
    @start_date = start_date
    @end_date = end_date
    @ind_count = []
    @ind_names = ind_names
    @ind_array = []
    @table = []
    @ind_cats = []
    @ind_dats = []
  end

  def execute
    clean_count(get_count)
    build_cats_data(@ind_count)
    build_table(@ind_cats, @ind_dats)
  end

  def clean_count(ind_count)
    sorted = sort_count(ind_count)
    reversed = reverse_count(sorted)
    save_count(reversed)
  end

  def get_count
    @ind_count = Rbandit::Trdopt.where(:ts => @start_date..@end_date).count(group: 'ind')
  end

  def sort_count(ind_count)
    ind_count.sort_by &:last
  end

  def reverse_count(ind_count)
    ind_count.reverse! 
  end

  def save_count(ind_count)
    @ind_count = ind_count
  end

  def build_cats_data(ind_count)
    @ind_cats = build_categories(ind_count)
    @ind_dats = build_data(ind_count)
    #build_data_array(@ind_dats)
  end

  def build_categories(ind_count)
    ind_count.map { |i| @ind_names.find { |n| n.id == i[0]}.name }
  end

  def build_data(ind_count)
    ind_count.map { |i| i[1] }
  end

  def build_data_array(data)
    data.each do |d|
      hash = {}
      hash["name"] = "Indicator"
      hash["data"] = [d]
      @ind_array << hash
    end
  end

  def build_table(cats, data)
    @table = cats.zip(data)
  end
end