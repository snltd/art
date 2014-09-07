#!/usr/bin/env ruby
# encoding: utf-8
#
# This script breaks up the old PHP site's index pages into YAML for the
# new Sinatra site. It uses eval(). Oh yeah.

require 'yaml'

infile = IO.read('index.php').encode(
  'UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''
).gsub("\n", ' ').gsub("\t", ' ')

regex = Regexp.new(' array\((".*?")\)')

infile.scan(regex).each do |p|
  e = eval("[#{p.first.squeeze("\s")}]")
  d = e[2].split('/')

  ret = { title: e[1],
          image: e[0],
          year: d.first.to_i,
          month: d.last.to_i,
          medium: e[3],
          x: e[4],
          y: e[5],
          price: e[6]
  }

  ret[:desc] = e[7] if e[7]

  File.open(ret[:image].sub(/\.\w*\z/, '.yaml'), 'w') do |f|
    f.puts ret.to_yaml
  end

end
