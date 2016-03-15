require 'data_mapper'

class Question
  include DataMapper::Resource

  property :id, Serial
  property :body, String
  property :question_type, Enum[:voice, :numeric, :yesno], default: :voice
  property :survey, String
  property :created_at, DateTime

  belongs_to :survey
  has n, :answers
end
