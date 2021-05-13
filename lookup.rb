def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(filelines) # filelines array(lines of a file) received as a parameter
  filelines.each { |line| filelines.delete(line) if (line[0] == "#" or line == "\r\n") }  # Filtering out comments and empty line.
  newhash = {}                        # Hash is build to store the lines of a file.
  i = 1
  filelines.each do |line|
    key = "Line"                      # key named Line for each line of a file
    line = (line.strip).split(", ")   # Line is striped and splited and added to the hash to the respected key
    newhash[key + i.to_s] = line
    i += 1
  end
  newhash
end

def resolve(record, chain, domain) # Hash(lines of a file),lookup chain and the domain received as parameter
  includearr = []                       # to store true or false whether the given domain is present in each line or not.
  record.each do |key, arr|
    includearr << arr.include?(domain)
    if (arr[1] == domain && arr[0] == "A") # if middle value of array is domain and if it is a A record
      return chain << arr[2]
    elsif (arr[1] == domain && arr[0] == "CNAME") # if middle value of array is domain and if it is a CName record
      chain << arr[2]
      return resolve(record, chain, arr[2])  # recursion
    end
  end
  chain[0] = "Error: record not found for #{domain}" if (includearr.all? { |a| a == false })  # if the domain name is not present in the record
  chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
