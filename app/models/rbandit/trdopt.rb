class Rbandit::Trdopt < Rbandit::TradeBase
  self.table_name = 'trdopt'

  belongs_to :instropt, :foreign_key => :optid
  belongs_to :trdindopt, :foreign_key => :ind
  belongs_to :exchopt, :foreign_key => :exchcode

  def underlying_name
    underlying_name if underlying
  end

  def underlying_name=(name)
    self.underlying = Rbandit::Instropt.find_by_underlying(name) unless name.blank?
  end

end