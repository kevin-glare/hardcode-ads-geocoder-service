task :configurable do
  require 'dotenv/load'
  require 'dry-configurable'
  require_relative '../../config/initializers/configurable'
end
