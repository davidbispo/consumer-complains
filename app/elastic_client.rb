class ElasticClient
  def initialize(url, request_class, body)
    @url =  url
    @request_class = request_class
    @body = body
  end

  def perform
    @uri = URI.parse(@url)
    http = Net::HTTP.new(@uri.host, @uri.port)
    request = @request_class.new(@uri, {'Content-Type' => 'application/json'})
    if Sinatra::Base.production?
      http.use_ssl = true
      request["Authorization"] = "Basic ZWxhc3RpYzpFdVNvcDVnOGpaTHdlVmNLd0FHQkR1VHM="
    end
    request.body = @body.to_json if @body
    response = http.request(request)
  end
end