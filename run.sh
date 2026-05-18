#!/bin/sh

stack build
echo 'stack exec raspi-finance-database -- <args>'
stack exec raspi-finance-database

exit 0
