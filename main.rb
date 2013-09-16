#!/usr/bin/env ruby

require 'bundler/setup'
require 'id3tag'
require 'optparse'
require 'pp'
require 'ostruct'

default = {}
args = {}
$usage

OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on('-d', '--dir [DIRECTORY]', 'DIRECTORY containing mp3s') do |dir|
    args[:directory] = dir
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end

  $usage = opts
end.parse!

options = OpenStruct.new(default.merge(args))

def recurse(hierarchy, metadata, file_path)
  if File.file?(file_path)
    number_and_title = metadata[:title].split('.').first
    result = /^(?<number>\d+)\s+(?<title>.+)$/.match(number_and_title)

    metadata[:title] = result[:title]
    metadata[:number] = result[:number]

    # TODO: AOMAN: Set ID3 data here.
    puts metadata
  else
    first, *rest = hierarchy
    Dir.open(file_path).select { |f| !f.match(/^\./) }.each do |sub_file_path|
      recurse(rest, metadata.merge(first => sub_file_path), File.join(file_path, sub_file_path))
    end
  end
end

recurse([:artist, :album, :title], {}, options.directory)
