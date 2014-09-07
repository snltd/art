#!/usr/bin/env ruby

# Quick script to turn the old PHP definition file into YAML.
#
require 'date'
require 'yaml'

infile = IO.read('definitions_1-116.php').gsub("\s+", ' ').gsub("\n", ' ')
catalog = []
regex = Regexp.new('array\((\d.*?")\)')

infile.scan(regex).each do |p|
  e = eval("[#{p.first.squeeze("\s")}]")
  date = Date.strptime(e[1])

  picinfo = {
    number: e[0],
    title: e[5],
    image: "#{'%03d' % e[0]}.jpg",
    year: date.year,
    month: date.month,
    day: date.day,
    col: e[3],
    row: e[4],
    medium: "#{e[2]} on masonite",
    x: 29,
    y: 29,
  }

  picinfo[:person] = e[6] if e[6]

  if picinfo[:row] == 9 || picinfo[:row] == 10
    picinfo[:row] = picinfo[:row] + 1
  end

  catalog << picinfo
end

catalog.sort_by!{|k| k[:number]}.to_yaml.each_line do |x|
  puts if x.match(/^- /)
  puts x
end
