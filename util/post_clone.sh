#!/bin/sh
# post_clone.sh - run after git clone


mkdir -p tmp
ln -s ../shared/log ./log
ln  ../shared/config/database.yml ./config/database.yml
ln -s ../shared/public/photos public/photos

touch db/test.db
rake db:schema:load RAILS_ENV=test

echo now run spec
