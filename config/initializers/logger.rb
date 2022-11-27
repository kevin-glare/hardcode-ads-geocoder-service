# frozen_string_literal: true

Application.configure do |app|
  logger = Ougai::Logger.new(
    app.root.concat('/', AppSetting.logger.path),
    level: AppSetting.logger.level
  )

  logger.before_log = lambda do |data|
    data[:service] = { name: AppSetting.app.name }
    data[:request_id] ||= Thread.current[:request_id]
  end

  app.set :logger, logger
end
