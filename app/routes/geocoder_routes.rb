# frozen_string_literal: true

class GeocoderRoutes < Application
  namespace '/api' do
    namespace '/v1' do
      post '/geocoder' do
        geocoder_params = validate_with!(GeocoderParamsContract)

        result = Geocoders::GeocodeService.call(*geocoder_params.to_h.values)
        if result.success?
          status 200
          coordinates = { coordinates: result.coordinates }
          json coordinates
        else
          status 422
          error_response result.errors
        end
      end
    end
  end
end
