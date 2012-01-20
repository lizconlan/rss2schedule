require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'haml'

require 'models/item'

before do
  MONGO_URL = ENV['MONGOHQ_URL'] || YAML::load(File.read("config/mongo.yml"))[:mongohq_url]
  env = {}
  MongoMapper.config = { env => {'uri' => MONGO_URL} }
  MongoMapper.connect(env)
end

helpers do
  include Rack::Utils
  
end

get '/' do
  @q = params[:q]

  
	haml :index
end

