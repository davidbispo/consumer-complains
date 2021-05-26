require_relative './elastic_client'
require_relative './utils'

class Services
  ES_HOST = Sinatra::Base.production? ? "http://elasticsearch" : "https://elasticsearch"
  class << self
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
      obj = {}
      if offset || per_page
        obj = pagination_config(offset, per_page)
      end
      if sort_field && sort_order
        obj[:sort] = sort_config(sort_field, sort_order)
      end
      obj[:query] = { match_all: {} }
      url =  "#{ES_HOST}/complains/_search"
      @client = ElasticClient.new(
        url,
        Net::HTTP::Get,
        obj
      )
      response = @client.perform
    end

    def get_one_complaint(complain_id)
      url =  "#{ES_HOST}/complains/_doc/#{complain_id}"
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
      body = create_body(description, title, location)
      response = get_one_complaint(complain_id)
      if response.code != "404"
        url =  "#{ES_HOST}/complains/_doc/#{complain_id}"
        @client = ElasticClient.new(url, Net::HTTP::Put, body)
        return @client.perform
      else
        return self.create_complaint(description, title, location)
      end
    end

    def destroy_complaint(complain_id)
      url =  "#{ES_HOST}/complains/_doc/#{complain_id}"
      @client = ElasticClient.new(url, Net::HTTP::Delete, {})
      response = @client.perform
    end

    private

    def create_body(description, title, location)
      {
        title: title,
        description: description,
        location: location,
        created_at: Time.now.strftime("%Y/%m/%d %H:%M:%S")
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

      pagination_args = ["offset", "per_page"]
      pagination_search_args = search_hash.select { |k,v| pagination_args.include?(k) }

      sort_args = ["sort_field", "sort_order"]
      sort_search_args = search_hash.select { |k,v| sort_args.include?(k) }


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

      if !pagination_search_args.empty?
        argz = [pagination_search_args["offset"], pagination_search_args["per_page"]]
        body = body.merge(pagination_config(*argz))
      end
      if sort_search_args.length == 2
        body[:sort] = sort_config(sort_search_args["sort_field"], sort_search_args["sort_order"])
      end
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

    def pagination_config(offset=nil, per_page=nil)
      base = {}
      base[:from] = offset if offset
      base[:size] = per_page if per_page
      base
    end

    def sort_config(sort_field, sort_order)
      [ { "#{sort_field}" => { order: sort_order } } ]
    end
  end
end