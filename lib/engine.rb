require 'kramdown'

def sections
  S_DIR.children.select(&:directory?).map { |s| format('/%s', s.basename) }
end

def markdown(raw)
  Kramdown::Document.new(raw, KRAMDOWN_OPTS).to_html
end

def section_contents(section)
  toc = Pathname.glob(S_DIR + section + '*.yaml').map do |f, a|
    YAML.load(IO.read(f)).tap { |p| p[:fpath] = f.basename.sub_ext('') }
  end

  toc.sort_by { |h| [DateTime.new(h[:year], h[:month]), h[:title]] }.reverse
end

def pic_info(section, piece)
  YAML.load(IO.read(S_DIR + section + "#{piece}.yaml"))
rescue
  raise Sinatra::NotFound
end

def pic_links(section)
  section_contents(section).map { |f| f[:fpath].to_s }
end

def section_name(section)
  YAML.load(IO.read(S_DIR + "#{section}.yaml"))[:title]
end

def series_name(series)
  YAML.load(IO.read(S_DIR + 'series' + "#{series}.yaml"))[:title]
end

def pic_info_116(filter = nil)
  defs = YAML.load(IO.read(S_DIR + 'series' + '1-116' + 'definitions.yaml'))

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

def pic_links_116
  YAML.load(IO.read(S_DIR + 'series' + '1-116' + 'definitions.yaml'))
end

def sort_116_by_date(data)
  data.sort_by { |i| Date.strptime("#{i[:year]}-#{i[:month]}-#{i[:day]}") }
end

