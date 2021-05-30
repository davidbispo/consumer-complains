require_relative '../../../app/api'
require_relative '../../../app/services'
require_relative '../../../app/utils'
require_relative '../../../app/mappings'

RSpec.describe 'POST /complains' do
  def app
    ConsumerComplaints::API
  end

  context "and correct arguments are passed" do
    context "and record exists" do
      before do
        argz = [ new_complain_ok["title"], new_complain_ok["description"], new_complain_ok["location"] ]
        @new_complain_id = JSON.parse(Services::create_complaint(*argz).read_body)["_id"]
        put("/complains/#{@new_complain_id}", new_complain_replace.to_json, { 'CONTENT_TYPE' => 'application/json' })
      end

      it "expects a correct response" do
        expect(last_response.status).to eq(201)
      end

      it "expects the complain to have been replaced" do
        result = Services::get_one_complaint(@new_complain_id)
        parsed = JSON.parse(result.body)["_source"]
        expect(parsed.except('id', 'created_at')).to match(new_complain_replace)
      end
    end
    context "and record DOES NOT exist" do
      before do
        put("/complains/potato", new_complain_replace.to_json, { 'CONTENT_TYPE' => 'application/json' })
        @new_complain_id = last_response.body
      end
      it "expects a correct response from the API" do
        expect(last_response.status).to eq(201)
      end

      it "expects the complain to have been created" do
        result = Services::get_one_complaint(@new_complain_id)
        parsed = JSON.parse(result.body)["_source"]
        expect(parsed.except('id', 'created_at')).to match(new_complain_replace)
      end
    end
  end
  context "and incorrect arguments are passed" do
    context "record exists" do
      before do
        argz = [ new_complain_ok["title"], new_complain_ok["description"], new_complain_ok["location"] ]
        @new_complain_id = JSON.parse(Services::create_complaint(*argz).read_body)["_id"]
        put("/complains/#{@new_complain_id}", new_complain_replace.to_json, { 'CONTENT_TYPE' => 'application/json' })
      end

      it "expects 422" do
        put("/complains/#{@new_complain_id}", new_complain_nok.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(last_response.status).to eq(422)
      end
    end
    context "record does not exist" do
      it "expects 422" do
        put("/complains/potato", new_complain_nok.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(last_response.status).to eq(422)
      end
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
      "lname" => "John",
      "state" => "PR",
      "country" => "Brasil"
    }
  end
end