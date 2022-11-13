# frozen_string_literal: true

I18n.load_path += Dir[Application.root.concat('/config/locales/**/*.yml')]
I18n.available_locales = AppSetting.i18n.available_locales
I18n.default_locale = AppSetting.i18n.default_locale
