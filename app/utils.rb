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
  end
end