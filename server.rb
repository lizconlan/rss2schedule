require 'sinatra'
require 'mongo_mapper'
require 'haml'

require './models/item'

before do
  MONGO_URL = ENV['MONGOHQ_URL'] || YAML::load(File.read("config/mongo.yml"))[:mongohq_url]
  env = {}
  MongoMapper.config = { env => {'uri' => MONGO_URL} }
  MongoMapper.connect(env)
end

get '/' do
  @count = Item.all.count
  @last_updated = Item.all[@count-1].created_at
  haml :index
end