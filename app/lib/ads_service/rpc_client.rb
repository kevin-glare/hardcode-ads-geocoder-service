# frozen_string_literal: true

require 'securerandom'
require_relative 'rpc_api'

module AdsService
  class RpcClient
    include RpcApi
    extend Dry::Initializer[undefined: false]

    option :queue, default: proc { create_queque }
    option :reply_queue, default: proc { create_reply_queue }
    option :lock, default: proc { Mutex.new }
    option :condition, default: proc { ConditionVariable.new }

    def self.fetch
      Thread.current['ads_service.rpc_client'] ||= new.start
    end

    def start
      @reply_queue.subscribe do |delivery_info, properties, payload|
        if properties[:correlation_id] == @correlation_id
          @lock.synchronize { @condition.signal }
        end
      end

      self
    end

    private

    attr_writer :correlation_id

    def create_queque
      channel = RabbitMq.channel
      channel.queue('ads_geocoder', durable: true)
    end

    def create_reply_queue
      channel = RabbitMq.channel
      channel.queue('amq.rabbitmq.reply-to', durable: true)
    end

    def publish(payload, opts = {})
      self.correlation_id = SecureRandom.uuid
      Thread.current[:request_id] ||= @correlation_id
      @lock.synchronize do
        @queue.publish(
          payload,
          opts.merge(
            app_id: AppSetting.app.name,
            correlation_id: @correlation_id,
            reply_to: @reply_queue.name,
            headers: {
              request_id: Thread.current[:request_id]
            }
          )
        )

        @condition.wait(@lock)
      end
    end
  end
end
