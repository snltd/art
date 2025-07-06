# frozen_string_literal: true

require 'kramdown'

def sections
  S_DIR.children.select(&:directory?).map { |s| format('/%s', s.basename) }
end

def markdown(raw)
  Kramdown::Document.new(raw, KRAMDOWN_OPTS).to_html
end

def section_contents(section)
  toc = Pathname.glob(S_DIR.join(section, '*.yaml')).map do |f, _a|
    YAML.load_file(f).tap { |p| p[:fpath] = f.basename.sub_ext('') }
  end

  toc.sort_by { |h| [DateTime.new(h[:year], h[:month]), h[:title]] }.reverse
end

def pic_info(section, piece)
  YAML.load_file(S_DIR.join(section, "#{piece}.yaml"))
rescue StandardError
  raise Sinatra::NotFound
end

def pic_links(section)
  section_contents(section).map { |f| f[:fpath].to_s }
end

def section_name(section)
  YAML.load_file(S_DIR.join("#{section}.yaml"))[:title]
end

def series_name(series)
  YAML.load_file(S_DIR.join('series', "#{series}.yaml"))[:title]
end

def pic_info116(filter = nil)
  defs = YAML.load_file(S_DIR.join('series', '1-116', 'definitions.yaml'))

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

def pic_links116
  YAML.load_file(S_DIR.join('series', '1-116', 'definitions.yaml'))
end

def sort_116_by_date(data)
  data.sort_by { |i| Date.strptime("#{i[:year]}-#{i[:month]}-#{i[:day]}") }
end
