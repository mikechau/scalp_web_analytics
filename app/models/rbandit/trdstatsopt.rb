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

  def self.top_volume(start_date, end_date, underlying_name, limit_amt)

    date_match = (start_date == end_date)

    case date_match
    when true 
      if underlying_name == ''
        top = self.joins(:instropt).where("ds = ?", start_date).select('volume, instropt.underlying, instropt.expiration, instropt.strike, instropt.callput').order('volume DESC').limit(limit_amt)
      else
        top = self.joins(:instropt).where("ds = ? AND instropt.underlying = ?", start_date, underlying_name).select('volume, instropt.underlying, instropt.expiration, instropt.strike, instropt.callput').order('volume DESC')
      end
    when false
      if underlying_name == ''
        top = self.joins(:instropt).where("ds >= ? AND ds <= ?", start_date, end_date).select('volume, instropt.underlying, instropt.expiration, instropt.strike, instropt.callput').order('volume DESC').limit(limit_amt)
      else
        top = self.joins(:instropt).where("ds >= ? AND ds <= ? AND instropt.underlying = ?", start_date, end_date, underlying_name).select('volume, instropt.underlying, instropt.expiration, instropt.strike, instropt.callput').order('volume DESC')
      end
    end

    top.map! { |t| {:underlying => t.underlying, :expiration => t.expiration, :strike => t.strike, :option => t.callput, :volume => t.volume } }
  end

end