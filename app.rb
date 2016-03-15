require 'sinatra/base'
require_relative './helpers/datamapper_helper'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

database_url = 'postgres://localhost/automated_survey_sinatra'
DataMapperHelper.setup(database_url)

module AutomatedSurvey
  class App < Sinatra::Base
    set :show_exceptions, false
    set :raise_errors, false
    set :root, File.dirname(__FILE__)

    # surveys
    get '/surveys/call' do
      'Automated Survey Sinatra'
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
