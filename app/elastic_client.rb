class ElasticClient
  def initialize(url, request_class, body)
    @url =  url
    @request_class = request_class
    @body = body
  end

  def perform
    @uri = URI.parse(@url)
    http = Net::HTTP.new(@uri.host, 9200)
    http.use_ssl = true unless Sinatra::Base.development?

    request = @request_class.new(@uri, {'Content-Type' => 'application/json'})
    request.body = @body.to_json
    response = http.request(request)
  end
end