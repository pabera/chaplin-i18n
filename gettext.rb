src_dir = "src/coffee/templates/**/*.haml"
dst_file = "locale/application.pot"
$po = {}

def read_dir(dir)
  Dir.glob(dir).each do |file|
    read_file(file) if File.file? file
  end
end

# read a single file
def read_file(file)
  line_counter = 0
  File.open(file, "r") do |content|
    while (line = content.gets)
      # magic
      line_counter += 1
      given = parse_line(line)

      if given
        $po[given[0]] = [] unless $po[given[0]]      
        $po[given[0]].push("#: "+ file +":" + line_counter.to_s)
      end
    end
  end
end

# Parse given line for gettext and return string if there is any
def parse_line(line)
  line.scan(/{{\s*t\s["']([^\n]*)['"].*}}/)[0]
end

def create_po_syntax
  text = ""

  $po.each do | key, value |
    value.each do | file_name |
      text += file_name + "\n"
    end

    text += "msgid \"" + key + "\"\n"
    text += "msgstr \"\"\n\n"
  end
  text
end

# save parsed data to pot file
def save_pot_file(file)
  path = file.scan(/([^\n]*)\/([^\n]*)/)[0]
  locale_folder = path[0]
  pot_file = path[1]

  Dir.mkdir(locale_folder) unless File.directory?(locale_folder)
  File.delete pot_file if File.exists? pot_file
  
  output = File.new(locale_folder +"/"+ pot_file, "w+")
  output << create_po_syntax
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
save_pot_file(dst_file)
