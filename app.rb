require 'sinatra/base'
require 'data_mapper'

require_relative 'models/survey'
require_relative 'models/question'
require_relative 'models/answer'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

database_url = 'postgres://localhost/automated_survey_sinatra'
DataMapper.setup(:default, database_url)
DataMapper.finalize

# this section automatically creates the tables
Survey.auto_upgrade!
Question.auto_upgrade!
Answer.auto_upgrade!

module AutomatedSurvey
  class App < Sinatra::Base
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.dirname(__FILE__)

    get '/' do
      'Automated Survey Sinatra'
    end

    error do |exception|
      'An error has ocurred'
    end
  end
end
