
require_relative '../../../app/api'
require_relative '../../../app/services'
require_relative '../../../app/utils'
require_relative '../../../app/mappings'

BASE_URL = '/complain'

RSpec.describe 'DELETE /complain/:id' do
  def app
    ConsumerComplaints::API
  end

  before(:all) do
    Utils::create_index('complains', Mappings::COMPLAINS) unless Utils::index_exists?('complains')

    @complain_ids = []
    (0..2).each do |idx|
      complain = new_complains[idx]
      argz = [ complain[:description], complain[:title], complain[:location] ]
      @complain_ids << JSON.parse(Services::create_complaint(*argz).read_body)["_id"]
    end
    sleep 2
  end

  context "record is found" do

    it "expects a confirmation from the API" do
      delete("#{BASE_URL}/#{@complain_ids[1]}")
      expect(last_response.status).to eq(200)
    end
  end

  context "record is NOT found" do

    it "expects a 404 from the API" do
      delete("#{BASE_URL}/_doc/sdasdasd")
      expect(last_response.status).to eq(404)
    end
  end

  def new_complains
    [{
      "title": "First Complain",
      "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rhoncus facilisis lectus, vitae accumsan ante fermentum vitae. Vivamus ultrices enim eget ipsum aliquet hendrerit ac rutrum purus. Donec posuere placerat diam quis feugiat. Vivamus non dolor et nulla luctus egestas quis ac lectus. Sed auctor nec leo sed commodo. Mauris eget tortor eget lectus elementum eleifend. Sed rutrum nisi et gravida bibendum.",
      "location": {
        "coordinates":{
          "lat": 40.12,
          "lon": -71.34
        },
        "city": "São Jose dos pinhais",
        "state": "PR",
        "country": "Brasil"
      }
    },
    {
      "title": "Second Complain",
      "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rhoncus facilisis lectus, vitae accumsan ante fermentum vitae. Vivamus ultrices enim eget ipsum aliquet hendrerit ac rutrum purus. Donec posuere placerat diam quis feugiat. Vivamus non dolor et nulla luctus egestas quis ac lectus. Sed auctor nec leo sed commodo. Mauris eget tortor eget lectus elementum eleifend. Sed rutrum nisi et gravida bibendum.",
      "location": {
        "coordinates":{
          "lat": 40.12,
          "lon": -71.34
        },
        "city": "São Jose dos pinhais",
        "state": "PR",
        "country": "Brasil"
      }
    },
    {
      "title": "Third Complain",
      "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rhoncus facilisis lectus, vitae accumsan ante fermentum vitae. Vivamus ultrices enim eget ipsum aliquet hendrerit ac rutrum purus. Donec posuere placerat diam quis feugiat. Vivamus non dolor et nulla luctus egestas quis ac lectus. Sed auctor nec leo sed commodo. Mauris eget tortor eget lectus elementum eleifend. Sed rutrum nisi et gravida bibendum.",
      "location": {
        "coordinates":{
          "lat": 40.12,
          "lon": -71.34
        },
        "city": "São Jose dos pinhais",
        "state": "PR",
        "country": "Brasil"
      }
    },
  ]
  end
end