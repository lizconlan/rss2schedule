require 'rubygems'

require 'bundler'
Bundler.setup

require 'rake'

require 'mongo_mapper'
require 'time'
require 'rcov'

#parser libraries
require 'lib/rss_parser'

#persisted models
require 'models/item'

# MONGO_URL = ENV['MONGOHQ_URL'] || YAML::load(File.read("config/mongo.yml"))[:mongohq_url]
# 
# env = {}
# MongoMapper.config = { env => {'uri' => MONGO_URL} }
# MongoMapper.connect(env)

desc 'temporary thing to show that the parser is working'
task :parser_test do
  p = RSSParser.new
  p.parse
end