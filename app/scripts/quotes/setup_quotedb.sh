#!/bin/bash

DB="../../../db/quotes.sqlite3"

sqlite3 ${DB} "create table forex (
		id integer primary key,
		symbol string,
		date date,
		close decimal);"

sqlite3 ${DB} "create table forex_symbols (
		id integer primary key,
		currency_to string, currency_from string,
		last date, begin date, auto boolean);"

# try using varchar(40) if smaller...
sqlite3 ${DB} "create table quotes (
		id integer primary key,
		symbol string,
		date date, open decimal, high decimal, low decimal,
		close decimal, volume decimal, adjclose decimal);"
		
sqlite3 ${DB} "create table quote_symbols (
		id integer primary key,
		symbol string, last date, begin date, auto boolean);"

