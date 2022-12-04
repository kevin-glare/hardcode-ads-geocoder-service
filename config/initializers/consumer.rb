# frozen_string_literal: true

require 'json'

channel = RabbitMq.consumer_channel
queue = channel.queue('geocoding', durable: true)

queue.subscribe(manual_ack: true) do |delivery_info, properties, payload|
  Thread.current[:request_id] = properties.headers["request_id"]

  payload = JSON(payload)
  Application.logger.info "Payload: #{payload}" if Application.environment == :development

  coordinates = Geocoder.geocode(payload['city'])
  Application.logger.info "Coordinates: #{coordinates}" if Application.environment == :development

  if coordinates.present?
    client = AdsService::RpcClient.fetch
    client.update_coordinates(payload['id'], coordinates)
  end

  channel.ack(delivery_info.delivery_tag)
end
