require 'sinatra/base'
require_relative './elastic_client'
require_relative './services'

module ConsumerComplaints
  class API < Sinatra::Base
    require 'json'
    require 'net/http'
    require "sinatra/reloader" if development?

    configure :development do
      register Sinatra::Reloader
      also_reload './services'
      also_reload './elastic_client'
      also_reload './utils'
    end
    set :server, 'puma'

    before do
      if @request.content_type == 'application/json'
        @request.body.rewind
        @request_payload = JSON.parse(request.body.read) rescue nil
      end
    end

    get '/' do
      return { status: "ok" }.to_json
    end

    get '/complains' do
      content_type :json
      begin
        args = [
          params["offset"],
          params["per_page"],
          params["sort_field"],
          params["sort_order"]
        ]
        response = Services::list_all_complaints(*args)
        return Utils::format_elastic_response(response.read_body) if response.code == "200"
      rescue => e
        halt 500, e.message
      end
      halt 400
    end

    get '/complain/:id' do
      content_type :json
      begin
        response = Services::get_one_complaint(params["id"])
        return Utils::format_elastic_response(response.read_body) if response.code == "200"
      rescue => e
        halt 422, e.message
      end
      halt 404 if response.code == '404'
      halt 500
    end

    post '/complains' do
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
        if response.code == "201" || response.code == "200"
          status 201
          return JSON.parse(response.read_body)["_id"]
        end
      rescue => e
        halt 422, e.message
      end
      halt 500
    end

    post '/complains/search' do
      content_type :json
      permitted = [
        "city",
        "distance",
        "lat",
        "long",
        "state",
        "title",
        "description",
        "offset",
        "per_page",
        "sort_field",
        "sort_order"
      ]
      @body = @request_payload.select { |k,v| permitted.include?(k) }

      response = Services::search_complaint(@body)
      return Utils::format_elastic_response(response.read_body) if response.code == "200"
      halt 422
    end

    delete '/complain/:id' do
      response = Services::destroy_complaint(params[:id])
      return status 200 if response.code == "200"
      halt 400
    end
  end
end
