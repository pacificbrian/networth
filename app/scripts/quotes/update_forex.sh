#!/bin/bash
#
# oanda.com download of forex currency rates
#
# Copyright © 2010-2014 Brian Welty <bkwelty@zoho.com>
#
# This file is part of Networth.
# 
# Networth is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# Networth is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [ ! $RAILS_ROOT ]; then
  DB="../../../db/quotes.sqlite3"
else
  DB="$RAILS_ROOT/db/quotes.sqlite3"
fi
echo using $DB

for x in $@; do
	
CURRENCY_FROM=$x
CURRENCY=USD
CURL_TICKER=${CURRENCY_FROM}${CURRENCY}=X
TICKER=`echo $CURL_TICKER | sed -e 's/[-=.]//g'`

if [ ! $TICKER ]; then
	echo "invalid TICKER = $TICKER"
	exit
fi

echo "Fetching $TICKER"

TODAY=`date "+%Y%m%d"`
TODAY_DATE2=`date "+%m/%d/%y"`

LAST_DATE=`sqlite3 ${DB} "select last from forex_symbols where currency_from = \"${CURRENCY_FROM}\""`

if [ $LAST_DATE ]; then
	if [ $LAST_DATE -eq $TODAY ]; then
		echo $TICKER is current
		exit
	fi

	new_quote=
	START_MONTH=`echo ${LAST_DATE} | cut -c 5-6`
	START_DAY=`echo ${LAST_DATE} | cut -c 7-8`
	START_YEAR=`echo ${LAST_DATE} | cut -c 3-4`
	START_DATE2="$START_MONTH/$START_DAY/$START_YEAR"
else
	new_quote=1
	START_DATE2="08/01/07"
	TODAY_DATE2="06/01/08"
fi
first_quote=-1

curl -o /tmp/${TICKER}-${TODAY}.csv "http://www.oanda.com/convert/fxhistory?date_fmt=us&date=${TODAY_DATE2}&date1=${START_DATE2}&exch=${CURRENCY_FROM}&expr=${CURRENCY}&lang=en&margin_fixed=0&format=CSV&redirected=1"

new_quotes=`cat /tmp/${TICKER}-${TODAY}.csv | awk -f oanda.awk`

head_quotes=`echo $new_quotes | wc -w`
echo Got $head_quotes quotes.
if [ ! $head_quotes -gt 0 ]; then
	echo Unable to retrieve $TICKER quotes.
	exit
fi

echo Updating quotes for $TICKER
line=0
start_date_set=
OLD_LAST_DATE=0
if [ $LAST_DATE ]; then
	OLD_LAST_DATE=${LAST_DATE}
fi
for x in $new_quotes; do

#	echo $x
	if [ $line -gt $first_quote ]; then
		A=`echo $x | cut -d, -f 1`
		A=`echo $A | sed -e 's/[-.]//g'`
		B=`echo $x | cut -d, -f 2`

		START_M=`echo ${A} | cut -c 1-2`
		START_D=`echo ${A} | cut -c 4-5`
		START_Y=`echo ${A} | cut -c 7-10`
		A="$START_Y$START_M$START_D"

		if [ ! $start_date_set ]; then
			START_DATE=${A}
			start_date_set=1
		fi

		if [ ${A} -gt $OLD_LAST_DATE ]; then
			LAST_DATE=${A}
			sqlite3 ${DB} "insert into forex (symbol, date, close) values (\"${CURL_TICKER}\", ${A}, ${B});"
		fi
	fi
	line=$[$line+1]

done

echo Updating last of $TICKER in forex_symbols
if [ $new_quote ]; then
	sqlite3 ${DB} "insert into forex_symbols (currency_to, currency_from, last) values (\"${CURRENCY}\", \"${CURRENCY_FROM}\", ${LAST_DATE});"
	sqlite3 ${DB} "update forex_symbols set begin = ${START_DATE} where currency_from = \"${CURRENCY_FROM}\";"
else
	sqlite3 ${DB} "update forex_symbols set last = ${LAST_DATE} where currency_from = \"${CURRENCY_FROM}\";"
fi

done	# for each TICKER
