class Rbandit::Opnintopt < Rbandit::TradeBase
  self.table_name = 'opnintopt'

  belongs_to :instropt, :foreign_key => :optid

end