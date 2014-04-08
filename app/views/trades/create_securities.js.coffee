$j('#cash_flows').html '<%= j render(:partial => 'cash_flows/cash_flow', :locals  => {:cash_flows => @account.ordered_cash_flows_by_year(@year), :balance => @account.cash_balance}) %>'
$j('#securities').html '<%= j render(:partial => 'securities/security', :locals  => {:account=> @account, :securities=> @account.securities}) %>'
$j('#total').html '<%= j render(:partial => 'accounts/total', :locals  => {:account => @account}) %>'
