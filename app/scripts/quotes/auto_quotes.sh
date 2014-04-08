#!/bin/sh

DB="../../../db/quotes.sqlite3"
DB_BACKUP="../../../db/quotes_backup.sqlite3"

cp $DB $DB_BACKUP

symbols=`sqlite3 $DB "select symbol from quote_symbols where auto = 't'"`
for x in $symbols; do
	if [ $x ]; then
		./update_quote.sh $x
	fi
done

symbols=`sqlite3 $DB "select currency_from from forex_symbols where auto = 't'"`
for x in $symbols; do
	if [ $x ]; then
		./update_forex.sh $x
	fi
done

