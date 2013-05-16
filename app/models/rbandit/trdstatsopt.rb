require 'safe_attributes/base'
class Rbandit::Trdstatsopt < Rbandit::TradeBase
  include SafeAttributes::Base
  self.table_name = "trdstatsopt"

  bad_attribute_names :open
  belongs_to :instropt, :foreign_key => :optid

  def open_price= value
    self[:open] = value
  end

  def open_price
    self[:open]
  end

end