class Rbandit::Trdindopt < Rbandit::TradeBase
  self.table_name = 'trdindopt'
  has_many :trdopts, :foreign_key => :ind
end