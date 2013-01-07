#!/bin/sh

# mgup.sh  migrate dbs [development, teest] 

rake db:migrate && rake db:migrate RAILS_ENV=test