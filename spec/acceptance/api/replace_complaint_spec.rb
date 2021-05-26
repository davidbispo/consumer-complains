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
    context "and record exists" do
      before do
        argz = [ new_complain[:title], new_complain[:description], new_complain[:location] ]
        @new_complain_id = JSON.parse(Services::create_complaint(*argz).read_body)["_id"]
      end

      it "expects a correct response" do
        put("#{BASE_URL}/#{@new_complain_id}", new_complain_ok.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(last_response.status).to eq(201)
      end

      it "expects the complain to have been replaced" do
        result = Services::get_one_complaint(@new_complain_id)
        byebug
        parsed = JSON.parse(result)["results"][0]
        expect(parsed.except('id', 'created_at')).to match(new_complain_ok)
      end
    end
    context "and record DOES NOT exist" do
      it "expects a correct response from the API" do
        put(BASE_URL, new_complain_ok.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(last_response.status).to eq(201)
        @created_complain =  Services::get_one_complaint(@new_complain_id)
      end

      it "expects the complain to have been created" do
        result = Services::get_one_complaint(@created_complain)
        parsed = JSON.parse(result)["results"][0]
        expect(parsed.except('id', 'created_at')).to match(new_complain_ok)
      end
    end
  end

  context "and incorrect arguments are passed" do
    context "record exists" do
      it "expects 422" do
        put(BASE_URL, new_complain_nok.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(last_response.status).to eq(422)
      end
    end
    context "record does not exist" do
      it "expects 422" do
        put(BASE_URL, new_complain_nok.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(last_response.status).to eq(422)
      end
    end
  end

  def new_complain
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
  def new_complain_replace
    {
      "title" => "Second Complain",
      "description" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rhoncus facilisis lectus, vitae accumsan ante fermentum vitae. Vivamus ultrices enim eget ipsum aliquet hendrerit ac rutrum purus. Donec posuere placerat diam quis feugiat. Vivamus non dolor et nulla luctus egestas quis ac lectus. Sed auctor nec leo sed commodo. Mauris eget tortor eget lectus elementum eleifend. Sed rutrum nisi et gravida bibendum.",
      "location" => {
        "coordinates" =>{
          "lat" => 40.12,
          "lon" => -71.34
        },
        "city" => "Aracaju",
        "state" => "SE",
        "country" => "Brasil"
      }
    }
  end
  def new_complain_nok
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
end