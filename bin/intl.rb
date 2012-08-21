#!/usr/bin/env ruby
# encoding: utf-8

require "json"
require "yaml"

class Internationalization

  CONFIG_FILE = 'config.yml'
  
  def initialize
    load_config
  end

  # Convert all PO files in a given src folder to the equivilant dst folder JSON file
  def po_to_json
    files = read_dir(@config['paths']['to_json']['src'])

    files.each do |file|
      # Setup, read file
      _lang     = File.basename(file, '.po')
      _file     = File.open(file, "r:iso-8859-1:utf-8")
      _content  = _file.read

      # Parse translations
      _translation = _content.scan(/^msgid \"([^\n]+)\"\n^msgstr \"([^\n]+)\"$/)

      # Transform to JSON and return
      _json = { _lang => {} }
      _translation.each { |key,value| _json[_lang][key] = value }
      
      # Save file
      save_file(_json.to_json, _lang +".json", @config['paths']['to_json']['dst'])
    end
  end

  # Reads a src folder of templates and parses all i18n strings to a POT file
  def create_pot
    _translations = {}

    # Parse all templates and write unique strings to 
    templates = read_dir(@config['paths']['to_pot']['src'])
    templates.each do |template|
      line_counter = 0
      
      # Parse single template file
      File.open(template, "r") do |content|
        while(line = content.gets)
          line_counter += 1
          parsed_line = line.scan(/{{\s*t\s["']([^\n]*)['"].*}}/)[0]

          # Translation strings should be unique
          if parsed_line
            _translations[parsed_line[0]] = [] unless _translations[parsed_line[0]]
            _translations[parsed_line[0]].push("#: "+ template +":" + line_counter.to_s)
          end
        end
      end
    end

    # Write the POT file out of the _translation hash
    pot_syntax = ""
    _translations.each do | key, value |
      value.each do | file_name |
        pot_syntax += file_name + "\n"
      end

      pot_syntax += "msgid \"" + key + "\"\n"
      pot_syntax += "msgstr \"\"\n\n"
    end

    # extract dst folder and dst file from given config
    path = @config['paths']['to_pot']['dst'].scan(/([^\n]*)\/([^\n]*)/)[0]
    # save file
    save_file(pot_syntax, path[1], path[0])
  end

  def set_config(root, type, value)
    puts root, type, value
    @config['paths'][root][type] = value
    puts @config['paths'][root][type]
  end

  private

  # load config file
  def load_config
    @config = YAML::load_file(CONFIG_FILE)
  end

  def read_dir(dir)
    Dir.glob(dir)
  end

  def read_file(file, option)
    file = File.open(file, option)
  end

  def save_file(content, filename, dst)
    # Setup
    file = dst + "/" + filename
    Dir.mkdir(dst) unless File.directory?(dst)
    File.delete file if File.exists? file

    # Write data
    output = File.new(file, "w+")
    output << content
    output.close

    puts "File created: " + file
  end

end

# Decide wether you want to parse templates (read) or create json (write)
intl = Internationalization.new

puts ARGV.to_s

if ARGV[0] == "read" || !ARGV[0]
  puts 'Read templates and create POT file'

  # Use with caution: you can pass your src and dst as parameters too
  # Currently no exception handling though
  if ARGV[1] && ARGV[2]
    intl.set_config('to_pot', 'src', ARGV[1])
    intl.set_config('to_pot', 'dst', ARGV[2])
  end
  
  intl.create_pot
elsif ARGV[0] == "write"
  puts 'Transform all PO to JSON files'
  
  # Use with caution: you can pass your src and dst as parameters too
  # Currently no exception handling though
  if ARGV[1] && ARGV[2]
    intl.set_config('to_json', 'src', ARGV[1])
    intl.set_config('to_json', 'dst', ARGV[2])
  end
  
  intl.po_to_json
end