require_relative '../../../app/api'
require_relative '../../../app/services'
require_relative '../../../app/utils'
require_relative '../../../app/mappings'

RSpec.describe 'GET /complains' do
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
    sleep 1
  end

  context "no pagination and sort args" do
    it "expects a correct response from the API" do
      get "/complains"
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      expect(parsed).not_to be_empty
    end
  end

  context "and there are pagination options" do
    context "and only offset" do
      it "expects pagination to be correct" do
        get "/complains"
        unpaginated = JSON.parse(last_response.body)

        get "/complains?offset=1"
        expect(last_response.status).to eq(200)
        paginated = JSON.parse(last_response.body)

        expect(paginated["results"][0]).to match(unpaginated["results"][1])
        expect(paginated["results"][1]).to match(unpaginated["results"][2])
      end
    end
    context "and only per page" do
      it "expects a correct response from the API" do
        get "/complains"
        unpaginated = JSON.parse(last_response.body)
        expect(unpaginated["results"].length).to eq(3)

        get "/complains?per_page=2"
        expect(last_response.status).to eq(200)
        paginated = JSON.parse(last_response.body)

        expect(paginated.length).to eq(2)
      end
    end
    context "and offset and per page" do
      it "expects a correct response from the API" do
        get "/complains"
        unpaginated = JSON.parse(last_response.body)

        get "/complains?offset=1&per_page=2"
        expect(last_response.status).to eq(200)
        paginated = JSON.parse(last_response.body)

        expect(paginated[0]).to match(unpaginated[1])
        expect(paginated[1]).to match(unpaginated[2])
        expect(paginated.length).to eq(2)
      end
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