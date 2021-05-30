require_relative '../../../app/api'
require_relative '../../../app/services'
require_relative '../../../app/utils'
require_relative '../../../app/mappings'

RSpec.describe 'GET /complains' do

  before(:all) do
    Utils::create_index('complains', Mappings::COMPLAINS) unless Utils::index_exists?('complains')

    @complain_ids = []
    (0..3).each do |idx|
      complain = new_complains[idx]
      argz = [ complain["description"], complain["title"], complain["location"] ]
      @complain_ids << JSON.parse(Services::create_complaint(*argz).read_body)["_id"]
    end
    sleep 1
  end

  def app
    ConsumerComplaints::API
  end

  context "search by term" do
    context "and term exists" do
      context "and no pagination" do
        let(:body) do
          {
            title: "First complain",
            description: "Lorem",
          }
        end
        it "expects Only first complain to be fetched" do
          post("/complains/search", body.to_json, { 'CONTENT_TYPE' => 'application/json' })
          parsed = JSON.parse(last_response.body)
          expect(last_response.status).to eq(200)

          expect(parsed["results"][0].except('id', 'created_at')).to match(new_complains[0])
        end
      end
      context "and pagination is active" do
        let(:unpaginated_body) do
          {
            title: "Second complain",
          }
        end

          let(:paginated_body) do
            {
              title: "Second complain",
              offset: "1",
              per_page: "5"
            }
        end
        it "expects the results to be paginated" do
          post "/complains/search", unpaginated_body.to_json, { 'CONTENT_TYPE' => 'application/json' }
          unpaginated = JSON.parse(last_response.body)

          post("/complains/search", paginated_body.to_json, { 'CONTENT_TYPE' => 'application/json' })
          paginated = JSON.parse(last_response.body)

          expect(paginated[0]).to match(unpaginated[1])
          expect(paginated[1]).to match(unpaginated[2])
        end
      end
      context "and sorting is active" do
        let(:sorted_body) do
          {
            title: "Second complain",
            sort_field: "created_at",
            sort_order: "asc"
          }
        end
        it "expects the results to be sorted" do
          post("/complains/search", sorted_body.to_json, { 'CONTENT_TYPE' => 'application/json' })
          response = JSON.parse(last_response.body)
          sorted_created = response["results"].map {|r| r["created_at"]}
          expect(sorted_created).to match(sorted_created.sort)
        end
      end
    end
  end

  context "search by location and term" do
    context "and is within location" do
      let(:body) do
        {
          title: "complain",
          sort_field: "created_at",
          sort_order: "asc",
          distance: "100km",
          lat: -25.42417783923112,
          lon: -49.27113134554342,
        }
      end
      it "expects the proper results to be found" do
        post("/complains/search", body.to_json, { 'CONTENT_TYPE' => 'application/json' })
        response = JSON.parse(last_response.body)
        expect(response.length).to eq(2)
      end
    end
    context "and is not within location" do
      let(:body) do
        {
          title: "second complain",
          sort_field: "created_at",
          sort_order: "asc",
          distance: "100km",
          lat: -20.0417783923112,
          lon: -46.27113134554342,
        }
      end
      it "expects the proper results to be found" do
        post("/complains/search", body.to_json, { 'CONTENT_TYPE' => 'application/json' })
        response = JSON.parse(last_response.body)
        expect(response["results"]).to be_empty
      end
    end
  end

  def new_complains
    [{
      "title" => "First Complain",
      "description" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      "location" => {
        "coordinates" =>{
          "lat" => -25.436776131028594,
          "lon" => -49.238994159386806
        },
        "city" => "Curitiba",
        "state" => "PR",
        "country" => "Brasil"
      }
    },
    {
      "title" => "Second Complain",
      "description" => "Ut rhoncus facilisis lectus, vitae accumsan ante fermentum vitae.",
      "location" => {
        "coordinates" =>{
          "lat" => -25.44776724738841,
          "lon" => -49.24204200794855
        },
        "city" => "Curitiba",
        "state" => "PR",
        "country" => "Brasil"
      }
    },
    {
      "title" => "Second Complain For real",
      "description" => "Fusce sed sem ut magna aliquam imperdiet",
      "location" => {
        "coordinates" => {
          "lat" => -23.539552086756164,
          "lon" => -46.63494044003388
        },
        "city" => "São Paulo",
        "state" => "SP",
        "country" => "Brasil"
      }
    },
    {
      "title" => "Third Complain",
      "description" => "Vivamus non dolor et nulla luctus egestas quis ac lectus.",
      "location" => {
        "coordinates" =>{
          "lat" => -19.9217475693605,
          "lon" => -43.945169429050765
        },
        "city" => "Belo Horizonte",
        "state" => "MG",
        "country" => "Brasil"
      }
    }
  ]
  end
end