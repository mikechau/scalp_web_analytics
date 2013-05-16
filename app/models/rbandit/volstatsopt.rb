class Rbandit::Volstatsopt < Rbandit::TradeBase
  self.table_name = 'volstatsopt'

  belongs_to :instropt, :foreign_key => :optid
end