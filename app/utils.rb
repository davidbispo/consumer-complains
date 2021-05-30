require_relative './mappings'
require_relative './elastic_client'

ES_HOST = Sinatra::Base.production? ?
  "https://i-o-optimized-deployment-0a4090.es.southamerica-east1.gcp.elastic-cloud.com:9243" :
  "http://elasticsearch:9200"
class Utils
  class << self
    def format_elastic_response(result)
      a = JSON.parse(result)
      search = a["hits"]
      if search
        total = a["hits"]["total"]["value"] if a["hits"]
        results = a["hits"]["hits"] || a["_source"]
        re = []
        results.each do |result|
          result["_source"]["id"] = result["_id"]
          re << result["_source"]
        end
        {
          total: re.length,
          results: re
        }.to_json
      else
        re = {
         result: a["_source"]
        }
        re[:id] = a["_id"]
        re.to_json
      end
    end

    def drop_index(index_name)
      url =  "#{ES_HOST}/#{index_name}"
      @client = ElasticClient.new(url, Net::HTTP::Delete, {})
      response = @client.perform
    end

    def create_index(index_name, mapping)
      url =  "#{ES_HOST}/#{index_name}"
      @client = ElasticClient.new(
        url,
        Net::HTTP::Put,
        mapping
      )
      response = @client.perform
    end

    def index_exists?(index)
      url =  "#{ES_HOST}/#{index}"
      @client = ElasticClient.new(url, Net::HTTP::Get, nil)
      response = @client.perform
      return response.code == "200"
    end
  end
end
