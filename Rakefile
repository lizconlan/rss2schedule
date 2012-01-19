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
require 'rspec/core/rake_task'

MONGO_URL = ENV['MONGOHQ_URL'] || YAML::load(File.read("config/mongo.yml"))[:mongohq_url]

env = {}
MongoMapper.config = { env => {'uri' => MONGO_URL} }
MongoMapper.connect(env)

desc 'parse the all.rss file'
task :parse_rss do
  p = RSSParser.new
  p.parse
end

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc  "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:rcov) 
end