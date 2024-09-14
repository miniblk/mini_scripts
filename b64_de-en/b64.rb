# frozen_string_literal: true

require 'base64'
require 'optparse'

parser = OptionParser.new
result = nil

parser.on('-d', '--decode string') do |encoded_str|
  result = Base64.decode64(encoded_str)
end

parser.on('-e', '--encode string') do |str|
  excluded_flag = ARGV.find_index { |arg| arg.start_with?('-') }
  content = [str, ARGV[0...excluded_flag]].join(' ') # Handle input without quotations
  binary_data = content.encode('UTF-8').force_encoding('ASCII-8BIT')
  result = Base64.strict_encode64(binary_data)
end

parser.on('--export [file]') do |filename|
  filename ||= 'output.txt'

  raise 'Nothing to export...' if result.nil? || result.empty?

  File.write(filename, "#{result}\n", mode: 'a')
rescue RuntimeError => e
  puts e
end

# parser.on('--import file') do |file|
#   raise "File #{file} doesn't exist" unless File.exist?(file)

#   File.readlines(file).each do |line|
#     puts Base64.decode64(line)
#   end
# rescue RuntimeError => e
#   puts e
# end

parser.parse!
puts result
