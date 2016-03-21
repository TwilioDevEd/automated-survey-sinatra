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

    DataMapperHelper.setup(self.settings.database_url)
    DataMapperHelper.seed_if_empty

    # home
    get '/' do
      erb :index
    end

    # surveys
    get '/surveys/voice' do
      survey = Survey.first()
      twiml = TwimlGenerator.generate_for_incoming_call(survey, RequestHelper.base_url(request))

      content_type 'text/xml'
      twiml
    end

    get '/surveys/sms' do
      twiml = ''
      origin_id = request.cookies['origin_id']
      question_id = request.cookies['question_id']

      if origin_id != nil && question_id != nil
        answer = Answer.create(
          digits: params[:body],
          origin_id: origin_id,
          from: params[:from],
          question_id: question_id.to_i
        )
        answer.save!
        question= Question.find_next(question_id.to_i)
        response.set_cookie "question_id", value: question.id
        twiml = TwimlGenerator.generate_for_sms_question(question, first_time: false)
      else
        # First time
        question = Question.get(1)
        response.set_cookie "question_id", value: question.id
        response.set_cookie "origin_id", value: Digest::SHA1.hexdigest(params[:sms_sid])[8..16]
        twiml = TwimlGenerator.generate_for_sms_question(question, first_time: true)
      end

      content_type 'text/xml'
      twiml
    end

    get '/surveys/results' do
      survey = Survey.first
      calls = Answer
        .all(fields: [:id, :origin_id], unique: true, order: nil)
        .collect{|a| a.origin_id}
        .uniq

      answers_per_call = Hash.new
      calls.each do |origin_id|
        answers_per_call[origin_id] = Answer.all(origin_id: origin_id)
      end

      erb :results, locals: {answers_per_call: answers_per_call, survey: survey}
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
      answer = Answer.create(
        recording_url: params[:recording_url],
        digits: params[:digits],
        origin_id: params[:call_sid],
        from: params[:from],
        question_id: params[:question_id].to_i
      )
      answer.save!

      next_question = Question.find_next(params[:question_id].to_i)
      twiml = next_question != nil ?
        TwimlGenerator.generate_for_voice_question(next_question) : TwimlGenerator.generate_for_exit

      content_type 'text/xml'
      twiml
    end

    error do |exception|
      p exception
      'An application error has ocurred'
    end
  end
end
