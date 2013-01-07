#!/bin/sh

echo DO this first: create a new gemset
echo rvm 1.8.7
echo rvm gemset create faxjax2
echo rvm gemset use faxjax2


gem install rails --version 1.2.6
gem install open_gem
gem install rmagick --version 2.9.1
gem install sqlite3
gem install pry pry-doc
gem install mailcatcher
gem list factory_girl --remote
gem install factory_girl
gem install factory_girl_rails
gem install capistrano
gem list faskefs
gem install fakefs timecop
gem install json
