$j('#trades').html '<%= j render(:partial => 'trades/trade', :locals  => {:security => @security, :trades => @security.trades.ordered_by_date}) %>'
