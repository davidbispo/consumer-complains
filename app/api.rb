require 'sinatra/base'
require_relative './elastic_client'
require_relative './services'

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

    before do
      @request.body.rewind
      @request_payload = JSON.parse(request.body.read) rescue nil
    end

    get '/' do
      content_type :json
      return { status: "ok" }.to_json
    end

    get '/complains/' do
      begin
        response = Services::list_all_complaints(
          params["offset"],
          params["per_page"],
          params["sort"]
        )
        return response.read_body if response.code == "200"
      rescue => e
        halt 500, e.message
      end
      halt 400
    end

    get '/complains/:id' do
      begin
        response = Services::get_one_complaint(params["id"])
        return response.read_body if response.code == "200"
      rescue => e
        halt 422, e.message
      end
      halt 500
    end

    post '/complains/' do
      required = ["description", "location", "title"]
      valid_required = @request_payload.keys.sort == required

      halt 422 unless valid_required

      begin
        response = Services::create_complaint(
          @request_payload["description"],
          @request_payload["title"],
          @request_payload["location"]
        )
        if response.code == "201"
          status 201
          return JSON.parse(response.read_body)["_id"]
        end
      rescue => e
        halt 422
      end
      halt 500
    end

    patch '/complains/:id' do
      begin
        response = Services::update_complaint(
          params["id"],
          @request_payload['description'],
          @request_payload['title'],
          @request_payload['location']
        )
        return status 200 if response.code == "200"
      rescue => e
        halt 422, e.message
      end
      halt 500
    end

    put '/complains/:id' do
      required = ["description", "location", "title"]
      valid_required = @request_payload.keys.sort == required

      halt 422 unless valid_required
      begin
        response = Services::replace_complaint(
          params['id'],
          @request_payload["description"],
          @request_payload["title"],
          @request_payload["location"]
        )
        return status 200 if response.code == "200"
      rescue => e
        halt 422, e.message
      end
      halt 500
    end

    post '/complains/search' do
      permitted = ["city", "distance", "lat", "long", "state", "title", "description"]
      @body = @request_payload.select { |k,v| permitted.include?(k) }

      response = Services::search_complaint(@body)

      return response.read_body if response.code == "200"
      halt 422
    end
  end
end