require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/cookies'
require 'tilt/erb'
require 'digest'
require_relative './helpers/datamapper_helper'
require_relative './helpers/request_helper'
require_relative './lib/twiml_generator'

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

    DataMapperHelper.setup(settings.database_url)
    DataMapperHelper.seed_if_empty

    # home
    get '/' do
      erb :index
    end

    # surveys
    get '/surveys/voice' do
      survey = Survey.first
      twiml = TwimlGenerator
              .generate_for_incoming_call(survey, RequestHelper.base_url(request))

      content_type 'text/xml'
      twiml
    end

    get '/surveys/sms' do
      twiml = ''
      origin_id = request.cookies['origin_id']
      question_id = request.cookies['question_id']

      if first_user_sms?
        Answer.create(
          digits: params[:Body],
          origin_id: origin_id,
          from: params[:From],
          question_id: question_id.to_i
        )
        question = Question.find_next(question_id.to_i)
        new_question_id = question.nil? ? nil : question.id
        response.set_cookie 'question_id', value: new_question_id
        twiml = TwimlGenerator.generate_for_sms_question(question, first_time: false)
      else
        question = Question.get(1)
        add_question_id_to_cookie(response, question.id)
        add_origin_id_to_cookie(params[:SmsSid])
        twiml = TwimlGenerator.generate_for_sms_question(question, first_time: true)
      end

      content_type 'text/xml'
      twiml
    end

    get '/surveys/results' do
      survey = Survey.first
      calls = Answer
              .all(fields: [:id, :origin_id], unique: true, order: nil)
              .map(&:origin_id)
              .uniq

      answers_per_call = {}
      calls.each do |origin_id|
        answers_per_call[origin_id] = Answer.all(origin_id: origin_id)
      end

      erb :results, locals: { answers_per_call: answers_per_call, survey: survey }
    end

    # questions
    get '/questions/:question_id' do
      question = Question.get(params[:question_id])
      twiml = TwimlGenerator.generate_for_voice_question(question)

      content_type 'text/xml'
      twiml
    end

    # answers
    post '/questions/:question_id/answers' do
      Answer.create(
        recording_url: params[:RecordingUrl],
        digits: params[:Digits],
        origin_id: params[:CallSid],
        from: params[:From],
        question_id: params[:question_id].to_i
      )

      next_question = Question.find_next(params[:question_id].to_i)
      if next_question.nil?
        twiml = TwimlGenerator.generate_for_exit
      else
        twiml = TwimlGenerator.generate_for_voice_question(next_question)
      end

      content_type 'text/xml'
      twiml
    end

    error do
      'An application error has ocurred'
    end

    private

    def first_user_sms?
      !(request.cookies['origin_id'].nil? && request.cookies['question_id'].nil?)
    end

    def add_question_id_to_cookie(response, question_id)
      response.set_cookie 'question_id', value: question_id
    end

    def add_origin_id_to_cookie(sms_sid)
      origin_id = Digest::SHA1.hexdigest(sms_sid)[8..16]
      response.set_cookie 'origin_id', value: origin_id
    end
  end
end
