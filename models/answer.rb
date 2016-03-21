require 'data_mapper'

class Answer
  include DataMapper::Resource

  property :id, Serial
  property :recording_url, String, length: 255
  property :digits, String
  property :origin_id, String
  property :from, String
  property :created_at, DateTime, :default => lambda{ |p,s| DateTime.now}

  belongs_to :question
end
