# frozen_string_litera: true

module Geocoders
  class GeocodeService
    prepend BasicService

    param :city

    attr_reader :city, :coordinates

    def call
      @coordinates = Geocoder.geocode(@city)
      fail!(I18n.t(:not_found, scope: 'services.errors')) if @coordinates.blank?
    end
  end
end
