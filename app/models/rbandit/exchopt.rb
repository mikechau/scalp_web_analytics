class Rbandit::Exchopt < Rbandit::TradeBase
  self.table_name = 'exchopt'
  has_many :trdopts, :foreign_key => :exchcode
end
