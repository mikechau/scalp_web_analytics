class Rbandit::TradeBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection("data_development")

  def readonly?
    true
  end

end
