require_relative './elastic_client'

class Services
  ES_HOST = Sinatra::Base.development? ? "http://elasticsearch" : "https://elasticsearch"
  class << self
    def index_exists?
      url =  "#{ES_HOST}/complains"
      @client = ElasticClient.new(url, Net::HTTP::Get, {})
      response = @client.perform
      return response.code == "200"
    end

    def search_complaint(search_hash)
      url =  "#{ES_HOST}/complains/_search"
      @client = ElasticClient.new(
        url,
        Net::HTTP::Post,
        search_body(search_hash)
      )
      response = @client.perform
    end

    def list_all_complaints(offset, per_page, sort_field, sort_order)
      url =  "#{ES_HOST}/complains/_search"
      @client = ElasticClient.new(
        url,
        Net::HTTP::Get,
        {
          from: offset,
          size: per_page,
          sort: [
            {
              "#{sort_order}" => {
                order: sort_field
              }
            }
          ],
          query: {
            match_all: {}
          }
        })
      response = @client.perform
    end

    def get_one_complaint(complaint_id)
      url =  "#{ES_HOST}/complains/_doc/#{complaint_id}"
      @client = ElasticClient.new(url, Net::HTTP::Get, {})
      response = @client.perform
    end

    def create_complaint(description, title, location)
      url =  "#{ES_HOST}/complains/_doc"
      body = create_body(description, title, location)
      @client = ElasticClient.new(url, Net::HTTP::Post, body)
      response = @client.perform
    end

    def update_complaint(complain_id, description, title, location)
      url =  "#{ES_HOST}/complains/_update/#{complain_id}"

      @client = ElasticClient.new(
        url,
        Net::HTTP::Post,
        {doc:create_body(description, title, location)},
      )
      response = @client.perform
    end

    def replace_complaint(complain_id, description, title, location)
      url =  "#{ES_HOST}/complains/_doc/#{complain_id}"
      body = create_body(description, title, location)
      @client = ElasticClient.new(url, Net::HTTP::Put, body)
      response = @client.perform
    end

    def destroy_complaint(complaint_id)
      url =  "#{ES_HOST}/complains/#{complain_id}"
      @client = ElasticClient.new(url, Net::HTTP::Delete, {})
      response = @client.perform
    end

    private

    def create_body(description, title, location)
      {
        title: title,
        description: description,
        location: location
      }
    end

    def update_body(description=nil, title=nil, location=nil)
     to_update = body[:doc]

     to_update["title"] = title if title
     to_update["description"] = description if description
     to_update["location"] = location if location
     to_update
    end

    def search_body(search_hash)
      geodistance_args = search_hash.select { |k,v| ["lat", "lon", "distance"].include?(k) }

      text_args = ["title", "description", "city", "state", "country"]
      text_search_args = search_hash.select { |k,v| text_args.include?(k) }

      body = {
        "query": {
          "bool": {
            "filter": [
            ]
          }
        }
      }
      body[:query][:bool][:filter] << geo_distance_config(*geodistance_args) unless geodistance_args.empty?
      body[:query][:bool][:filter] += word_match_config(text_search_args) unless text_search_args.empty?
      body
    end

    def geo_distance_config(distance, lat, lon)
      {
        "geo_distance": {
          "distance": distance.to_s,
          "location.coordinates": {
            "lat": lat.to_s,
            "lon": lon.to_s
          }
        }
      }
    end

    def word_match_config(args)
      base = []
      args.each do |key,value|
        location_keywords = ["city", "state", "country"]
        key = "location.#{key}" if location_keywords.include?(key)
        base <<
        {
          "bool": {
            "should": [
              {
                "match": {
                  "#{key}" => "#{value}"
                }
              }
            ]
          }
        }
      end
      base
    end
  end
end