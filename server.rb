#!/usr/bin/env ruby
# encoding: utf-8

require 'sinatra'
require 'pathname'
require 'date'
require 'yaml'
require 'haml'

#-----------------------------------------------------------------------------
# METHODS
#
def generate_toc(base, dir)
  #
  # Generate a table of contents of images
  #
  dirpath = base + 'content' + dir

  toc = Pathname.glob(dirpath + '*.yaml').reduce([]) do |ret, pth|
    info = YAML.load(File.open(pth))
    info[:fpath] = pth.basename.sub_ext('').to_s
    ret.<< info
    ret
  end

  toc.sort_by { |h| DateTime.new(h[:year], h[:month]) }.reverse
end

def get_pic_info(base, section, piece)
  #
  # fetch picture information. If we ever move to a DB, this will talk
  # to the DB.
  #
  YAML.load(File.open(base + 'content' + section + "#{piece}.yaml"))
end

def get_pic_links(base, section)
  generate_toc(base, section).map { |f| f[:fpath] }
end

def get_section_name(base, section)
  YAML.load(File.open(base + 'content' + "#{section}.yaml"))[:title]
end

def get_series_name(base, series)
  YAML.load(File.open(base + 'content' + 'series' + "#{series}.yaml"))[:title]
end

def get_116_info(base, filter = false)
  defs = YAML.load(File.open(base + 'content' + 'series' + '1-116' +
                              'definitions.yaml'))

  # The 42% paintings have a person's name attached, so we'll use that
  # fact to filter them out.

  if filter == '42'
    defs.select { |d| d[:person] }
  elsif filter == '58'
    defs.reject { |d| d[:person] }
  else
    defs
  end
end

def get_116_links(base)
  YAML.load(File.open(base + 'content' + 'series' + '1-116' +
                      'definitions.yaml'))
end

def haml_img(cell)
  "%img{src: \"/i/thumbs/1-116/large/#{cell[:image]}\"}"
end

def sort_116_by_date(data)
  data.sort_by! do |i|
    Date.strptime("#{i[:year]}-#{i[:month]}-#{i[:day]}")
  end
end

#-----------------------------------------------------------------------------
# SCRIPT STARTS HERE

base = Pathname(__FILE__).dirname
set :haml, format: :html5
defs_116 = get_116_links(base)

defs_116_by_date = defs_116.sort_by do |i|
  Date.strptime("#{i[:year]}-#{i[:month]}-#{i[:day]}")
end

breadcrumbs = { 'rdfisher.co.uk' => '/' }

get '/' do
  @nofooter = true
  haml :front_page
end

%w(/imperfect_reproduction /misc /squares_and_symbols /series
   /text_paintings).each do |path|
  get path do
    @base_url = path
    path[0] = '' if path[0] == '/'
    @links = generate_toc(base, path)
    @breadcrumbs = breadcrumbs.merge(get_section_name(base, path) => false)
    haml path.to_sym
  end
end

get '/series/1-116/extras/:page' do
  @breadcrumbs = breadcrumbs.merge(
    get_section_name(base, 'series') => '/series',
    '1-116' => "/series/1-116'}"
  )
  haml ('1-116_' + params[:page]).to_sym
end

get '/series/1-116/?:filter?/?:layout?' do
  @info = get_116_info(base, params[:filter])
  @breadcrumbs = breadcrumbs.merge(
    get_section_name(base, 'series') => '/series',
    '1-116' => false
  )
  @nomatch = "/#{params[:filter]}"
  @nomatch.<< "/#{params[:layout]}" if params[:layout]

  if params[:layout] == 'by_date'
    @info = sort_116_by_date(@info)

    @info.map! do |i|
      d = Date.strptime("#{i[:year]}-#{i[:month]}-#{i[:day]}")
      i[:dow] = d.strftime('%u').to_i
      i
    end
  end

  @numcols = (params[:filter] == '42') ? 7 : 8
  @layout = params[:layout]
  haml :'1-116'
end

get '/series/:series' do
  @base_url = File.join('series', params[:series])
  @links = generate_toc(base, File.join('series', params[:series]))
  @breadcrumbs = breadcrumbs.merge(
    get_section_name(base, 'series') => '/series',
    get_series_name(base, params[:series]) => false
  )
  haml params[:series].to_sym
end

get '/piece/:section/:title' do
  @navlinks = get_pic_links(base, params[:section])
  @info = get_pic_info(base, params[:section], params[:title])
  @info[:fpath] = params[:title]
  @info[:fdir] = params[:section]
  @pg_title = @info[:title]
  @breadcrumbs = breadcrumbs.merge(
    get_section_name(base, params[:section]) => "/#{params[:section]}"
  )
  haml :piece
end

get '/piece/series/1-116/:number' do
  n = params[:number].to_i
  @info = defs_116[n - 1]
  idx = defs_116_by_date.index(@info)

  @links = {
    by_num: {
      next: n + 1,
      prev: n - 1,
    },
    by_date: {
      next: idx < 115 ? defs_116_by_date[idx + 1][:number] : false,
      prev: idx > 0 ? defs_116_by_date[idx - 1][:number] : false,
    }
  }

  @breadcrumbs = breadcrumbs.merge(
    get_section_name(base, 'series') => '/series',
    '1-116' => "/series/1-116'}"
  )
  haml :piece_116
end

get '/piece/series/:section/:title' do
  @navlinks = get_pic_links(base, File.join('series', params[:section])).sort

  @info = get_pic_info(base, File.join('series', params[:section]),
                       params[:title])
  @info[:fpath] = params[:title]
  @info[:fdir] = File.join('series', params[:section]).to_s
  @pg_title = @info[:title]
  @breadcrumbs = breadcrumbs.merge(
    get_section_name(base, 'series') => '/series',
    get_series_name(base, params[:section]) => "/series/#{params[:section]}"
  )
  haml :piece
end

get '/:page' do
  @breadcrumbs = breadcrumbs
  haml params[:page].to_sym
end

