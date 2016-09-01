require 'csv'
require './lib/parser_base.rb'
Dir[File.dirname(__FILE__) + '/lib/parsers/**.rb'].each { |f| require f }

parsers = {
  krasnoeibeloe: RedAndWhiteParser
}

parser_classname = ARGV[0].to_sym

if !parsers.key?(parser_classname)
  puts "Parser #{parser_classname} not exist!"
else
  csv = CSV.open(ARGV[1], 'w')

  parser = parsers[parser_classname].new 
  parser.catalog_url = 'http://krasnoeibeloe.ru/catalog'
  #parser.result = csv
  parser.result = $stdout
  parser.run

  csv.close
end
