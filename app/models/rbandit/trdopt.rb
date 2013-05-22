class Rbandit::Trdopt < Rbandit::TradeBase
  self.table_name = 'trdopt'

  belongs_to :instropt, :foreign_key => :optid
  belongs_to :trdindopt, :foreign_key => :ind
  belongs_to :exchopt, :foreign_key => :exchcode

  def self.top_underlying(start_date, end_date)
    top = self.joins(:instropt).where(:ts => start_date..end_date).group('instropt.underlying').select('instropt.underlying, COUNT(*) as cnt')
    top.map! { |t| [t.underlying, t.cnt] }
    top = top.sort_by &:last
    top.reverse!
  end

  def self.top_indicators(start_date, end_date, underlying_name)
    if underlying_name == 'get_everything'
      top = self.where(:ts => start_date..end_date).group('trdopt.ind').select('trdopt.ind, COUNT(*) as cnt')
    else
      top = self.joins(:instropt).where("ts >= ? AND ts <= ? AND instropt.underlying = ?", start_date, end_date, underlying_name).group('trdopt.ind').select('trdopt.ind, COUNT(*) as cnt')
    end

    top.map! { |t| [t.ind, t.cnt] }
    top = top.sort_by &:last
    top.reverse!
  end
end