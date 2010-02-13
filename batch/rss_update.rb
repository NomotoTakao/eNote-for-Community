require "open-uri"
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'
require 'rss/dublincore'
require 'rss/syndication'
require 'rss/content'
require 'rss/trackback'
require 'rss/image'
 
#require "/app/rails/enotecloud/config/environment"
require "/Users/yoshikuni/workspace/eNote/config/environment"
require 'parsedate'

$KCODE = "u"

puts "RSS UPDATE IS STARTING .... #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}"

@trees = DRssTrunk.find(:all)

DRssTrunk.connection.execute("TRUNCATE TABLE d_rss_leaves;")

leaf_id = 1
@trees.each do |trunk|   
  puts "RSS-0 #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}"
  puts "RSS-1 #{trunk.rss_url}"
  ret = trunk.sync_rss_leaves
  puts "RSS-2 #{ret}"
end

puts "RSS UPDATE IS FINISHED. #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}"

