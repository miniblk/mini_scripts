# frozen_string_literal: true

require 'base64'
require 'optparse'

subtext = <<~HELP
  Example usage:
    ruby b64.rb --decode || --encode TEXT
    ruby b64.rb --decode || --encode TEXT --export output.txt
    --
    ruby b64.rb import --decode || --encode FILENAME
HELP

opts = {}

parser = OptionParser.new
parser.separator '╍╍╍╍'
parser.separator subtext
parser.separator '╍╍╍╍'

parser.on('-d', '--decode TEXT', 'Decode from Base64 format') do |encoded_str|
  puts "⮦ Decode: #{encoded_str}"
  puts '╍╍╍╍'
  Base64.decode64(encoded_str)
end

parser.on('-e', '--encode TEXT', 'Encode to Base64 format') do |str|
  excluded_flag = ARGV.find_index { |arg| arg.start_with?('-') }
  content = [str, ARGV[0...excluded_flag]].join(' ').strip # Handle input without quotations
  binary_data = content.encode('UTF-8').force_encoding('ASCII-8BIT').strip

  puts "⮦ Encode: #{content}"
  puts '╍╍╍╍'
  Base64.strict_encode64(binary_data)
end

parser.on('--export [file]', 'Export content to file') do |filename|
  filename ||= 'output.txt'

  raise 'Nothing to export...' unless opts.keys.any?

  puts "Exporting to #{filename}"

  File.write(filename, "#{opts.values.first}\n", mode: 'a')
rescue RuntimeError => e
  puts e
end

# Sub-command
import = OptionParser.new(:import)
parser.separator '╍╍╍╍'
parser.separator subtext
parser.separator '╍╍╍╍'
import.on('--decode file', 'Decode file content.') do |file|
  raise "File #{file} doesn't exist" unless File.exist?(file)

  puts "Decoding content of [#{file}]... #{file}"
  File.readlines(file).each do |line|
    puts "\x1b[32m#{Base64.decode64(line)}\033[0m"
  end
end

import.on('--encode file', 'Encode file content.') do |file|
  raise "File #{file} doesn't exist" unless File.exist?(file)

  puts "Encoding content of [#{file}]... "
  File.readlines(file).each do |line|
    binary_data = line.encode('UTF-8').force_encoding('ASCII-8BIT').strip
    puts "\x1b[32m#{Base64.strict_encode64(binary_data).inspect}\033[0m"
  end
end

subparser = { 'import' => import }

command = ARGV.first

 if command&.start_with?('-')
   parser.parse!(into: opts)
 elsif command.nil?
   puts parser, subparser.values
 else
   subparser[command].parse!
 end

%i[decode encode].any? { |k| puts "\x1b[32m⮡ #{opts[k]}\033[0m" if opts.key?(k) }
