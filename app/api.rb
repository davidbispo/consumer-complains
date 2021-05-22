require 'sinatra/base'
module ConsumerComplaints
  class API < Sinatra::Base
    require 'json'
    require 'net/http'
    require "sinatra/reloader" if development?
    require 'byebug' if development?

    configure :development do
      register Sinatra::Reloader
    end
    set :server, 'puma'

    ESHOST = Sinatra::Base.development? ? 'elasticsearch' : 'https://sdasdaosidj.io'
    PATH = '/student2/_search'
    # PATH = '/complains/_search?pretty=true'

    get '/' do
      content_type :json
      return { status: "ok" }.to_json
    end

    get '/complains/' do
      #get all complains
      return { status: "ok" }
    end

    get '/complains/:id' do
      #get specific complain
      return { status: "ok" }
    end

    post '/complains/' do
      #adds new complain
      return { status: "ok" }
    end

    patch '/complains/:id' do
      #updates complain
      return { status: "ok" }
    end

    put '/complains/:id' do
      #idempotently adds new complain
      return { status: "ok" }
    end

    post '/complains/search' do
      # request.body.rewind
      # @request_payload = JSON.parse(request.body.read)

      @url =  "http://#{ESHOST}#{PATH}"
      # permitted = ["city", "distance", "lat", "long", "state", "title"]

      # @body = @request_payload.select { |k,v| permitted.include?(key) }
      http = http_connection

      request = Net::HTTP::Post.new(@uri, {'Content-Type' => 'application/json'})
      request.body = request_body.to_json

      response = http.request(request)
      return response.read_body if response.code == "200"
      false
    end

    def http_connection
      @uri = URI.parse(@url)
      http = Net::HTTP.new(@uri.host, 9200)
      http.use_ssl = true unless Sinatra::Base.development?
      return http
    end

    def request_body()
      return {
        "query"=>{
          "bool"=>{
            "filter"=>[
              {
                "term"=>{"name"=>"david"}
              }, {"geo_distance"=>
              {
                "distance"=>"100km",
                "location"=>{
                  "lat"=>40.12,
                  "lon"=>-71.3
                  }
                }
              }
            ]
          }
        }
      }
    end
  end
end