require 'sinatra/base'
require 'sinatra/config_file'
require_relative './helpers/datamapper_helper'
require_relative './helpers/request_helper'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

module AutomatedSurvey
  class App < Sinatra::Base
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.dirname(__FILE__)

    register Sinatra::ConfigFile
    config_file 'config/app.yml'

    DataMapperHelper.setup(self.settings.database_url)
    DataMapperHelper.seed_if_empty

    # surveys
    get '/surveys/call' do
      survey = Survey.first()
      TwimlGenerator.generate_for_incoming_call(survey, RequestHelper.base_url(request))
    end

    get '/surveys/results' do
      'Automated Survey Sinatra'
    end

    # questions
    get '/questions/find/:question_id' do
      'Automated Survey Sinatra'
    end

    # answers

    post '/answers/create' do
      'Automated Survey Sinatra'
    end

    error do |exception|
      'An error has ocurred'
    end
  end
end
