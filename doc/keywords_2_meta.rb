#!/usr/bin/env ruby -wKU

mypath = File.dirname __FILE__
app_dir = File.expand_path(File.join(mypath, "..", "app"))
helpers_dir = File.join app_dir, "helpers"
views_dir = File.join(app_dir, "views")

require File.join(helpers_dir, "tag_helper")

include TagHelper

def meta_tag(attrs={})
  attrs["name"] = "keywords"
  _tga("meta", attrs)
end

path = File.join mypath, "keywords.txt"

keywords=[]
File.open(path, "r") do |f|
  f.each_line do |l|
    keywords << l.chomp
  end
end


keywords.map! {|k| "#{k}" }

meta = []
keywords.each_slice(4) do |slice|
  meta << slice.join(",")
end

meta.map! { |kws| meta_tag(:content => kws) }

File.open(File.join(views_dir, "_metatag.rhtml"), "w") do |f|
  f.puts "<% content_for :meta do %>"
  meta.each do |m|
    f.puts " #{m}"
  end
  f.puts "<% end %>"
end
