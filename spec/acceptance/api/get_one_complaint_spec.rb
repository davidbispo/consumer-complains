require_relative '../../../app/api'
require_relative '../../../app/services'
require_relative '../../../app/utils'

RSpec.describe 'GET /complain/:id' do
  def app
    ConsumerComplaints::API
  end

  context "the complain is found" do
    before do
      argz = [ new_complain[:title], new_complain[:description], new_complain[:location] ]
      @new_complain_id = JSON.parse(Services::create_complaint(*argz).read_body)["_id"]
    end

    it "expects a 200 from the API" do
      get "/complain/#{@new_complain_id}"
      expect(last_response.status).to eq(200)
    end

    it "correctly gets the complain" do
      get "/complain/#{@new_complain_id}"
      parsed = JSON.parse(last_response.body)
      expect(parsed).not_to be_empty
    end
  end

  context "the complain is NOT found" do
    it "expects a 404" do
      get "/complain/potato"
      expect(last_response.status).to eq(404)
    end
  end

  def new_complain
    {
      "title": "Fifth Complain",
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
    }
  end
end