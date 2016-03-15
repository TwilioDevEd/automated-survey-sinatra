require 'data_mapper'

class Answer
  include DataMapper::Resource

  property :id, Serial
  property :recording_url, String
  property :digits, String
  property :call_sid, String
  property :from, String
  property :created_at, DateTime

  belongs_to :question
end
