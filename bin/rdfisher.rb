#!/usr/bin/env ruby

require 'sinatra'
require 'pathname'
require 'English'
require 'date'
require 'yaml'
require 'slim'
require_relative '../lib/engine'

ROOT          = Pathname.new(__FILE__).dirname.parent.realpath
S_DIR         = ROOT + 'sections'
SECTIONS      = sections
KRAMDOWN_OPTS = { input:              'GFM',
                  syntax_highlighter: 'rouge',
                  hard_wrap:          false }.freeze

class WebApp < Sinatra::Base
  breadcrumbs = { 'rdfisher.co.uk': '/' }

  defs_116 = pic_links_116

  defs_116_by_date = defs_116.sort_by do |i|
    Date.strptime("#{i[:year]}-#{i[:month]}-#{i[:day]}")
  end

  set :root, ROOT

  get '/' do
    @nofooter = true
    slim :front_page
  end

  SECTIONS.each do |section|
    get section do
      @base_url = section
      section[0] = '' if section.start_with?('/')
      @links = section_contents(section)
      @breadcrumbs = breadcrumbs.merge(section_name(section) => false)
      slim section.to_sym
    end
  end

  get '/piece/:section/:title' do
    @navlinks = pic_links(params[:section])
    @info = pic_info(params[:section], params[:title])
    @info[:fpath] = params[:title]
    @info[:fdir] = '/' + params[:section]
    @pg_title = @info[:title]
    @breadcrumbs = breadcrumbs.merge(
      section_name(params[:section]) => "/#{params[:section]}"
    )
    slim :piece
  end

  get '/series/1-116/extras/:page' do
    @breadcrumbs = breadcrumbs.merge(
      section_name('series') => '/series', '1-116' => "/series/1-116'}"
    )
    slim ('1-116_' + params[:page]).to_sym
  end

  get '/series/1-116/?:filter?/?:layout?' do
    @info = pic_info_116(params[:filter])
    @breadcrumbs = breadcrumbs.merge(section_name('series') => '/series',
                                     '1-116' => false)
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

    @numcols = params[:filter] == '42' ? 7 : 8
    @layout = params[:layout]
    slim :'1-116'
  end

  get '/series/:series' do
    @base_url = format('series/%s', params[:series])
    @links = section_contents(@base_url)
    @breadcrumbs = breadcrumbs.merge(
      section_name('series') => '/series',
      series_name(params[:series]) => false
    )
    slim params[:series].to_sym
  end

  get '/piece/series/1-116/:number' do
    n = params[:number].to_i
    @info = defs_116[n - 1]
    idx = defs_116_by_date.index(@info)

    raise Sinatra::NotFound unless idx

    @links = {
      by_num: {
        next: n + 1,
        prev: n - 1
      },
      by_date: {
        next: idx < 115 ? defs_116_by_date[idx + 1][:number] : false,
        prev: idx > 0 ? defs_116_by_date[idx - 1][:number] : false
      }
    }

    @breadcrumbs = breadcrumbs.merge(
      section_name('series') => '/series', '1-116' => "/series/1-116'}"
    )
    slim :piece_116
  end

  get '/piece/series/:section/:title' do
    @navlinks = pic_links(format('series/%s', params[:section])).sort
    @info = pic_info(format('series/%s', params[:section]),
                            params[:title])
    @info[:fpath] = params[:title]
    @info[:fdir] = format('/series/%s', params[:section])
    @pg_title = @info[:title]
    @breadcrumbs = breadcrumbs.merge(
      section_name('series') => '/series',
      series_name(params[:section]) => "/series/#{params[:section]}"
    )
    slim :piece
  end

  get '/:page' do
    @breadcrumbs = breadcrumbs
    begin
      slim params[:page].to_sym
    rescue
      raise Sinatra::NotFound
    end
  end

  not_found do
    @breadcrumbs = nil
    @nofooter = true
    slim :error_page
  end

  run! if $PROGRAM_NAME == __FILE__
end
