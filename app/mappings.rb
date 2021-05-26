class Mappings
  COMPLAINS = {
    mappings: {
      properties: {
        created_at: { type: "keyword" },
        title: { "type": "text" },
        description: { "type": "text" },
        location: {
        properties: {
          coordinates: { "type": "geo_point" },
          city: { type: "text"  },
          state: { type: "text"  },
          country: { "type": "text"  }
          }
        }
      }
    }
  }
end