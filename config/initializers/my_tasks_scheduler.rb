require 'rufus/scheduler'
require 'json'
require 'httparty'
require 'rake'

################################
### SCHEDULERS
################################
initial_scheduler = Rufus::Scheduler.start_new
main_scheduler = Rufus::Scheduler.start_new


################################
### EXECUTION
################################
if defined?(Rails::Console)
  puts "You're in the console. Not running scheduler..."
else

  ################################
  ### INITIAL VARIABLES
  ################################
  @start_day = Date.today.beginning_of_day
  @finish_day = Date.today.end_of_day

  @ind_names = Rbandit::Trdindopt.all
  @exchanges = Rbandit::Exchopt.all

  @last_transaction = 0

  @first_trdopt_row = Rbandit::Trdopt.where(:ts => @start_day..@finish_day).first
  @first_trdstatsopt_row = Rbandit::Trdstatsopt.where(:ds => Date.today).first

  @last_trdopt_row = []
  @last_trdstatsopt_row = []

  ################################
  ### METHODS
  ################################

  def get_ind_name(ind)
    if ind == "TOTAL"
      return ind
    else
      @ind_names.find { |i| i[:id] == ind }.name
    end
  end

  def get_exch_name(exch)
    @exchanges.find { |e| e[:id] == exch }.name
  end

  def get_callput(letter)
    if letter == "P"
      "PUT"
    elsif letter == "C"
      "CALL"
    else
      "UNKN"
    end
  end

  #Everyday at 8:32am from Monday to Friday, this updates the variables
  initial_scheduler.cron '32 8 * * 1-5' do
    @start_day = Date.today.beginning_of_day
    @finish_day = Date.today.end_of_day
    @ind_names = Rbandit::Trdindopt.all
    @exchanges = Rbandit::Exchopt.all

    @last_transaction = 0
    @first_trdopt_row = Rbandit::Trdopt.where(:ts => @start_day..@finish_day).first
    @first_trdstatsopt_row = Rbandit::Trdopt.where(:ds => Date.today).first
  end

  main_scheduler.every '5s', allow_overlapping: false do
    @last_trdopt_row = Rbandit::Trdopt.last
    @last_trdstatsopt_row = Rbandit::Trdstatsopt.last

    ###########################
    ### INDICATORS
    ###########################
      ind_count = Rbandit::Trdopt.where(:id => @first_trdopt_row.id..@last_trdopt_row.id).count(group: 'ind')
      sorted_ind_count = (ind_count.sort { |a,b| a[1] <=> b[1] }).reverse
      ind_count = Hash[sorted_ind_count]
      ind_count["TOTAL"] = ind_count.values.sum

      ind_array = []

      ind_count.each do |k,v|
        input_hash = Hash.new
        input_hash["label"] = get_ind_name(k)
        input_hash["value"] = v
        ind_array << input_hash 
      end

      puts "Sending Indicators!"
      HTTParty.post('http://localhost:3030/widgets/indicators_list', :body => { auth_token: "YOUR_AUTH_TOKEN", items: ind_array }.to_json)

    ###########################
    ### TRANSACTION EXECUTED
    ###########################
      HTTParty.post('http://localhost:3030/widgets/total_transactions', :body => { auth_token: "YOUR_AUTH_TOKEN", current: ind_count["TOTAL"], last: @last_transaction }.to_json)

      @last_transaction = ind_count["TOTAL"]

    ###########################
    ### EXCHANGES
    ###########################
      exch_count = Rbandit::Trdopt.where(:id => @first_trdopt_row.id..@last_trdopt_row.id).count(group: 'exchcode')
      sorted_exch_count = (exch_count.sort { |a,b| a[1] <=> b[1] })
      exch_count = Hash[sorted_exch_count]
      exch_names = exch_count.keys
      exch_names.map! { |ex| get_exch_name(ex) }

      HTTParty.post('http://localhost:3030/widgets/highbar_ind', :body => { auth_token: "YOUR_AUTH_TOKEN", series: [{ data: exch_count.values }], categories: exch_names, color: '#efad1b' }.to_json)

    ###########################
    ### TOP 10 INSTS BY VOL
    ###########################
      top_insts = Rbandit::Trdstatsopt.includes(:instropt).where(:id => @first_trdstatsopt_row.id..@last_trdstatsopt_row.id).order('volume DESC').limit(10)

      top_insts_cats = []
      top_insts_data = []
      
      top_insts.each do |list|
        top_insts_cats << "#{list.instropt.underlying} - #{list.instropt.expiration} - #{list.instropt.strike.to_f} - #{get_callput(list.instropt.callput)}"
        top_insts_data << list.volume
      end

      HTTParty.post('http://localhost:3030/widgets/instruments', :body => { auth_token: "YOUR_AUTH_TOKEN", series: [{ name: 'Instruments', data: top_insts_data }], categories: top_insts_cats, color: '#2c3e50' }.to_json)

    ###########################
    ### RECENT TRADES
    ###########################
      recent_trades = Rbandit::Trdopt.includes(:instropt).where(:id => @last_trdopt_row.id-3..@last_trdopt_row.id)

      recent_trades_array = []

      recent_trades.each do |trade|
        input_hash = Hash.new
        input_hash["label"] = "[#{ trade.ts.strftime("%I:%M:%S %p") }] - #{ trade.instropt.underlying } | #{ trade.instropt.expiration } | Strike: $#{ trade.instropt.strike.to_f } | #{ get_callput(trade.instropt.callput) }"
        input_hash["value"] = "@ Price: $#{ trade.price.to_f} | Size: #{ trade.size } | Exchange: #{ get_exch_name(trade.exchcode) } | Indicator: #{get_ind_name(trade.ind)}"
        recent_trades_array << input_hash
      end

      recent_trades_array.reverse!

      HTTParty.post('http://localhost:3030/widgets/recent_trades_list', :body => { auth_token: "YOUR_AUTH_TOKEN", items: recent_trades_array }.to_json)

    ###########################
    ### TOP 5 UNDERLYING
    ###########################
      top_underlying = Rbandit::Trdopt.joins(:instropt).where(:id => @first_trdopt_row.id..@last_trdopt_row.id).group('instropt.underlying').select('instropt.underlying, COUNT(*) as cnt').order('cnt DESC').limit(5)
      top_underlying.map! { |t| [t.underlying, t.cnt] }

      underlying_array = []
      top_underlying.each do |u|
        input_hash = {}
        input_hash["name"] = u[0]
        input_hash["data"] = [u[1]]
        input_hash["pointWidth"] = 500
        underlying_array << input_hash
      end
      
      HTTParty.post('http://localhost:3030/widgets/stacker_symbols', :body => { auth_token: "YOUR_AUTH_TOKEN", series: underlying_array, color: '#d35400'}.to_json)

    ###########################
    ### TOP 5 SIZES
    ###########################
      top_sizes = Rbandit::Trdopt.includes(:instropt).where(:id => @first_trdopt_row.id..@last_trdopt_row.id).order("size DESC").limit(10)

      size_sample = top_sizes.map do |s|
        ["#{ s.instropt.underlying } - #{ s.instropt.expiration } @ $#{ s.instropt.strike.to_f } - #{ get_callput(s.instropt.callput) }", s.size.to_i]
      end

      size_sample.uniq!(&:first)

      sizes_data = size_sample.map { |data| data[1] }
      sizes_cats = size_sample.map { |cat| cat[0] }
      
      HTTParty.post('http://localhost:3030/widgets/top5_sizes', :body => { auth_token: "YOUR_AUTH_TOKEN", series: [{ name: 'Instruments', data: sizes_data }], categories: sizes_cats, color: '#95a5a6' }.to_json)

  end
end