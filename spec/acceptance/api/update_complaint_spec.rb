require_relative '../../../app/api'
require_relative '../../../app/services'
require_relative '../../../app/utils'
require_relative '../../../app/mappings'

RSpec.describe 'POST /complains' do
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

  context "and correct arguments are passed" do
    before do
      patch("/complains/#{@complain_ids[1]}", updated_complain.to_json, { 'CONTENT_TYPE' => 'application/json' })
    end
    it "expects a correct response from the API" do
      expect(last_response.status).to eq(200)
    end

    it "expects the complain to be persisted" do
      result = Services::get_one_complaint(@complain_ids[1])
      parsed = JSON.parse(result.body)["_source"]

      expect(parsed.except('id', 'created_at')).to match(updated_complain)
    end
  end

  context "and any incorrect arguments are passed" do
    it "expects 422" do
      post(BASE_URL, updated_complain_nok.to_json, { 'CONTENT_TYPE' => 'application/json' })
      expect(last_response.status).to eq(422)
    end
  end

  def new_complains
    [{
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
    },
    {
      "title" => "Second Complain",
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
    },
    {
      "title" => "Third Complain",
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
    },
  ]
  end

  def updated_complain
    {
      "title" => "Updated Complain",
      "description" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rhoncus facilisis lectus, vitae accumsan ante fermentum vitae. Vivamus ultrices enim eget ipsum aliquet hendrerit ac rutrum purus. Donec posuere placerat diam quis feugiat. Vivamus non dolor et nulla luctus egestas quis ac lectus. Sed auctor nec leo sed commodo. Mauris eget tortor eget lectus elementum eleifend. Sed rutrum nisi et gravida bibendum.",
      "location" => {
        "coordinates" =>{
          "lat" => 40.12,
          "lon" => -71.34
        },
        "city" => "Curitiba",
        "state" => "PR",
        "country" => "Brasil"
      }
    }
  end

  def updated_complain_nok
    {
      "fname" => "John",
      "lname" => "Doe",
      "location" => {
        "coordinates" =>{
          "lat" => 40.12,
          "lon" => -71.34
        },
        "city" => "Curitiba",
        "state" => "PR",
        "country" => "Brasil"
      }
    }
  end
end