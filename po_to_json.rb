#!/usr/bin/env ruby
# encoding: utf-8

require "json"

src_dir = "locale/*.po"
$dst_dir = "src/js/locale"

def read_dir(dir)
  Dir.glob(dir).each do |file|
    read_file(file) if File.file? file
  end
end

# read a single file
def read_file(file)
  file = File.open(file, "r:iso-8859-1:utf-8")
  lang = File.basename(file, '.po')
  
  content = file.read
  translations = parse_translation(content)
  json = convert_to_json(lang, translations)
  save_po_json_file(lang, json)
end

def parse_translation(content)
  content.scan(/^msgid \"([^\n]+)\"\n^msgstr \"([^\n]+)\"$/)
end

def convert_to_json(lang, translations)
  json = {}
  json[lang] = {}
  translations.each { |key,value| json[lang][key] = value }
  json.to_json
end

def save_po_json_file(lang, json)
  Dir.mkdir($dst_dir) unless File.directory?($dst_dir)
  File.delete lang+".json" if File.exists? lang+".json"

  output = File.new($dst_dir +"/"+ lang+".json", "w+")
  output << json
  output.close
end

# Do the real stuff, parse arguments if necessary, read the src and save the pot file
current = ""
ARGV.each do |a|
  if current ===  "--src"
    src_dir = a
    current = ""
  end

  if current ===  "--dst"
    dst_file = a
    current = ""
  end
  current = a if a === "--src" || a === "--dst"
end

read_dir(src_dir)