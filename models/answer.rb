require 'data_mapper'

class Answer
  include DataMapper::Resource

  property :id, Serial
  property :recording_url, String, length: 255
  property :user_input, String
  property :origin, String
  property :from, String
  property :created_at, DateTime, default: ->(_, _) { DateTime.now }

  belongs_to :question
end
