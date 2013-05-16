class Rbandit::Trdopt < Rbandit::TradeBase
  self.table_name = 'trdopt'

  belongs_to :instropt, :foreign_key => :optid
  belongs_to :trdindopt, :foreign_key => :ind
  belongs_to :exchopt, :foreign_key => :exchcode

end