# frozen_string_literal: true

class Configurable
  extend Dry::Configurable

  setting :i18n do
    setting :default_locale, default: :ru
    setting :available_locales, default: %i[en ru]
  end

  setting :rabbit_mq do
    setting :consumer_pool, default: ENV.fetch('RABBIT_MQ_CONSUMER_POOL', 2)
  end

  setting :secret_key_base, default: ENV.fetch('SECRET_KEY_BASE')
end

AppSetting = Configurable.config.freeze
