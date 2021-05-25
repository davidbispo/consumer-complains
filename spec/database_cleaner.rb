require_relative '../../../app/elastic_client'

ES_HOST = 'http://elasticsearch'

class DatabaseCleaner
  class << self
    def start
      url =  "#{ES_HOST}/complains"
      @client = ElasticClient.new(
        url,
        Net::HTTP::Delete,
        {}
      )
      @client.perform
      sleep 1
    end
  end
end