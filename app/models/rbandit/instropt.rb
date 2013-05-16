class Rbandit::Instropt < Rbandit::TradeBase
  self.table_name = 'instropt'

  has_many :trdstatsopt, :foreign_key => :optid
  has_many :trdopts, :foreign_key => :optid
  has_many :opnintopts, :foreign_key => :optid
end