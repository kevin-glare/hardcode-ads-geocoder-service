# frozen_string_literal: true

module RabbitMq
  extend self

  @mutex = Mutex.new

  def connection
    @mutex.synchronize do
      @connection ||= Bunny.new.start
    end
  end

  def channel
    Thread.current[:rabbitmq_channel] ||= connection.create_channel
  end

  def consumer_channel
    Thread.current[:rabbitmq_consumer_channel] ||= connection.create_channel(
      nil,
      AppSetting.rabbit_mq.consumer_pool.to_i
    )
  end
end
