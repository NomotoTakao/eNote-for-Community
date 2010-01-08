require "kconv"
require "open-uri"
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'
require 'rss/dublincore'
require 'rss/syndication'
require 'rss/content'
require 'rss/trackback'
require 'rss/image'
 
require "/app/rails/enote/config/environment"
#require "/Users/yoshikuni/workspace/enote/config/environment"
require 'parsedate'

$KCODE = "u"

puts "RSS UPDATE IS STARTING ...."

@trees = DRssTrunk.find(:all)

ActiveRecord::Base.connection.execute("TRUNCATE TABLE d_rss_leaves;")

leaf_id = 1
@trees.each do |trunk|   
  puts "RSS-1 #{trunk.rss_url}"
  ret = trunk.sync_rss_leaves
  puts "RSS-2 #{ret}"
end

puts "RSS UPDATE IS FINISHED."

