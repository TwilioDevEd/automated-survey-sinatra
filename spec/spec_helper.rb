ENV['RACK_ENV'] = 'test'

require 'database_cleaner'
require_relative '../app'
require_relative '../helpers/datamapper_helper'

RSpec.configure do |config|
  include Rack::Test::Methods

  database_url = 'postgres://localhost/automated_survey_sinatra_test'
  DataMapperHelper.setup(database_url)

  config.formatter = :documentation
  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  def app
    AutomatedSurvey::App
  end
end
