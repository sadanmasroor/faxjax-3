#!/bin/sh

# mgback.sh  migrate db back to $1

rake db:migrate VERSION=$1 && rake db:migrate VERSION=$1 RAILS_ENV=test