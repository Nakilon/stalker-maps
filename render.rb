require "pp"
require "byebug"

require "yaml"
ALL = YAML.load_file ARGV[0]
puts "ALL: #{ALL.size}"
abort if ALL.size < 1000

def fx x
  419 + x * 1.28
end
def fy y
  990 - y * 1.3725
end
