$j('#cash_flows').html '<%= j render(:partial => 'cash_flows/cash_flow', :locals  => {:cash_flows => @account.ordered_cash_flows_by_year(@year), :balance => @account.cash_balance}) %>'
$j('#total').html '<%= j render(:partial => 'accounts/total', :locals  => {:account => @account}) %>'
