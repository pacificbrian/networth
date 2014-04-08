#!/bin/bash
#
# Download of Yahoo! Quotes.
# For Yahoo foreign currencies, can only get current day conversion price.
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
	
CURL_TICKER=$x

TICKER=`echo $CURL_TICKER | sed -e 's/[-=.]//g'`

if [ ! $TICKER ]; then
	echo "invalid TICKER = $TICKER"
	exit
fi

echo "Fetching $x"

END_YEAR=`date "+%Y"`
END_MONTH=`date "+%m"`
END_DAY=`date "+%d"`
#END_YEAR=2008
#END_MONTH=11
#END_DAY=14
END_MONTH=$[10#$END_MONTH-1]

TODAY=`date "+%Y%m%d"`

LAST_DATE=`sqlite3 ${DB} "select last from quote_symbols where symbol = \"${CURL_TICKER}\""`

if [ $LAST_DATE ]; then
	if [ $LAST_DATE -eq $TODAY ]; then
		echo $TICKER is current
		exit
	fi

	new_quote=
	START_MONTH=`echo ${LAST_DATE} | cut -c 5-6`
	START_DAY=`echo ${LAST_DATE} | cut -c 7-8`
	START_YEAR=`echo ${LAST_DATE} | cut -c -4`
	START_MONTH=$[10#$START_MONTH-1]
else
	new_quote=1
	START_MONTH=0
	START_DAY=02
	START_YEAR=2007
	START_DATE=20070102
fi
first_quote=1

echo "curl -f http://ichart.finance.yahoo.com/table.csv?s=${CURL_TICKER}&d=${END_MONTH}&e=${END_DAY}&f=${END_YEAR}&g=d&a=${START_MONTH}&b=${START_DAY}&c=${START_YEAR}&ignore=.csv"

#curl -f -o /tmp/${TICKER}-${TODAY}.csv "http://ichart.finance.yahoo.com/table.csv?s=${CURL_TICKER}&d=${END_MONTH}&e=${END_DAY}&f=${END_YEAR}&g=d&a=${START_MONTH}&b=${START_DAY}&c=${START_YEAR}&ignore=.csv"

# curl -f to fail with no page if 401 errors
new_quotes=`curl -f "http://ichart.finance.yahoo.com/table.csv?s=${CURL_TICKER}&d=${END_MONTH}&e=${END_DAY}&f=${END_YEAR}&g=d&a=${START_MONTH}&b=${START_DAY}&c=${START_YEAR}&ignore=.csv"`

num_quotes=`echo $new_quotes | wc -w`
echo $num_quotes
if [ ! $num_quotes -gt 0 ]; then
	echo Unable to retrieve $TICKER quotes from http://ichart.finance.yahoo.com
	exit
fi

#echo $new_quotes

echo Updating quotes for $TICKER
line=0
last_date_set=
for x in $new_quotes; do

	#echo $x

	if [ $line -gt $first_quote ]; then
		A=`echo $x | cut -d, -f 1`
		A=`echo $A | sed -e 's/[-.]//g'`
		B=`echo $x | cut -d, -f 2`
		C=`echo $x | cut -d, -f 3`
		D=`echo $x | cut -d, -f 4`
		E=`echo $x | cut -d, -f 5`
		F=`echo $x | cut -d, -f 6`
		G=`echo $x | cut -d, -f 7`
		H=`echo $x | cut -d, -f 8`

		if [ ! $last_date_set ]; then
			echo "Setting LAST_DATE to ${A}"
			OLD_LAST_DATE=0
			if [ $LAST_DATE ]; then
				OLD_LAST_DATE=${LAST_DATE}
			fi
			LAST_DATE=${A}
			last_date_set=1
		fi

		if [ ${A} -gt $OLD_LAST_DATE ]; then
			START_DATE=${A}
			sqlite3 ${DB} "insert into quotes (symbol, date, open, high, low, close, volume, adjclose) values (\"${CURL_TICKER}\", ${A}, ${B}, ${C}, ${D}, ${E}, ${F}, ${G});"
		fi
	fi
	line=$[$line+1]

done

echo Updating last of $TICKER in quote_symbols
if [ $new_quote ]; then
	sqlite3 ${DB} "insert into quote_symbols (symbol, last, auto) values (\"${CURL_TICKER}\", ${LAST_DATE}, 't');"
	sqlite3 ${DB} "update quote_symbols set begin = ${START_DATE} where symbol = \"${CURL_TICKER}\";"
else
	sqlite3 ${DB} "update quote_symbols set last = ${LAST_DATE} where symbol = \"${CURL_TICKER}\";"
fi

done	# for each TICKER
