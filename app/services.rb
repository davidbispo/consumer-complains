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

    def list_all_complaints(offset, per_page, sort)
      url =  "#{ES_HOST}/complains/_search"
      @client = ElasticClient.new(
        url,
        Net::HTTP::Get,
        {
          # from: offset,
          # size: per_page,
          # sort:[
          #   {
          #     id:
          #       { order: "asc" }
          #   }]
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
      {}
    end
  end
end