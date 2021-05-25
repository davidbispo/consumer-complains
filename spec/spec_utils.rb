require_relative '../../../app/elastic_client'

ES_HOST = 'http://elasticsearch'

class SpecUtils
  class << self
    def create_index(index_name)
      url =  "#{ES_HOST}/#{index_name}"
      @client = ElasticClient.new(
        url,
        Net::HTTP::Delete,
        {}
      )
      @client.perform
  end
end