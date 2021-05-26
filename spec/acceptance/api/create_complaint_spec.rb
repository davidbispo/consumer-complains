require_relative '../../../app/api'
require_relative '../../../app/services'
require_relative '../../../app/utils'
require_relative '../../../app/mappings'

BASE_URL = '/complains'

RSpec.describe 'POST /complains' do
  def app
    ConsumerComplaints::API
  end

  context "and correct arguments are passed" do

    it "expects a correct response from the API" do
      post(BASE_URL, new_complain_ok.to_json, { 'CONTENT_TYPE' => 'application/json' })
      expect(last_response.status).to eq(201)

      @created_complain_id = last_response.body
    end

    it "expects the complain to be persisted" do
      result = Services::get_one_complaint(@created_complain_id)
      get "#{BASE_URL}"
      parsed = JSON.parse(last_response.body)["results"][0]

      expect(parsed.except('id', 'created_at')).to match(new_complain_ok)
    end
  end

  context "and any incorrect arguments are passed" do
    it "expects 422" do
      post(BASE_URL, new_complain_nok.to_json, { 'CONTENT_TYPE' => 'application/json' })
      expect(last_response.status).to eq(422)
    end
  end

  def new_complain_ok
    {
      "title" => "First Complain",
      "description" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rhoncus facilisis lectus, vitae accumsan ante fermentum vitae. Vivamus ultrices enim eget ipsum aliquet hendrerit ac rutrum purus. Donec posuere placerat diam quis feugiat. Vivamus non dolor et nulla luctus egestas quis ac lectus. Sed auctor nec leo sed commodo. Mauris eget tortor eget lectus elementum eleifend. Sed rutrum nisi et gravida bibendum.",
      "location" => {
        "coordinates" =>{
          "lat" => 40.12,
          "lon" => -71.34
        },
        "city" => "São Jose dos pinhais",
        "state" => "PR",
        "country" => "Brasil"
      }
    }
  end

  def new_complain_nok
    {
      "fname": "Darth",
      "lname": "Vader",
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