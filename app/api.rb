require 'sinatra/base'
require 'json'

module ConsumerComplaints
  class API < Sinatra::Base
    ESHOST = Sinatra::Base.development? ? 'elasticsearch' : 'https://sdasdaosidj.io'
    PATH = '/complains/_search?pretty=true'

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
      request.body.rewind
      @request_payload = JSON.parse(request.body.read)

      @url =  "http://#{ESHOST}#{PATH}"
      permitted = ["city", "distance", "lat", "long", "state", "title"]

      @body = @request_payload.select { |k,v| permitted.include?(key) }
      send_request
    end

    def send_request
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true unless Sinatra::Base.development?

      request = Net::HTTP::Post.new(uri, {'Content-Type' => 'application/json'})

      request.body = search_body.to_json
      response = http.request(request)

      return false unless response.code == 200
      response.body
    end

    def search_body
      return {
        query: {
          bool: {
            filter: [
              { term: { title: "david"} },
              {
                geo_distance:
                {
                  distance: "100km",
                  location:
                  {
                    lat: 40.12,
                    lon: -71.30,
                    city: "city",
                    state: "state"
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