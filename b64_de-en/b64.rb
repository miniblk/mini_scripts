# frozen_string_literal: true

require 'base64'
require 'optparse'

parser = OptionParser.new
opts = {}

parser.on('-d', '--decode [string]') do |encoded_str|
  opts[:decode] = true
  opts[:result] = '' || Base64.decode64(encoded_str)
end

parser.on('-e', '--encode [string]') do |str|
  opts[:encode] = true

  excluded_flag = ARGV.find_index { |arg| arg.start_with?('-') }
  content = [str, ARGV[0...excluded_flag]].join(' ') # Handle input without quotations
  binary_data = content.encode('UTF-8').force_encoding('ASCII-8BIT')
  opts[:result] = '' || Base64.strict_encode64(binary_data)
end

parser.on('--export [file]') do |filename|
  filename ||= 'output.txt'

  raise 'Nothing to export...' if opts[:result].nil? || opts[:result].empty?

  File.write(filename, "#{opts[:result]}\n", mode: 'a')
rescue RuntimeError => e
  puts e
end

parser.on('--import file') do |file|
  raise "File #{file} doesn't exist" unless File.exist?(file)

  File.readlines(file).each { |line| puts Base64.decode64(line) } if opts.key?(:decode)
  File.readlines(file).each { |line| puts Base64.encode64(line) } if opts.key?(:encode)
rescue RuntimeError => e
  puts e
end

parser.parse!(into: opts)
puts opts[:result]
