require 'data_mapper'

class Question
  include DataMapper::Resource

  property :id, Serial
  property :body, String, length: 255
  property :question_type, Enum[:voice, :numeric, :yesno], default: :voice
  property :created_at, DateTime, default: lambda{ |p,s| DateTime.now}

  belongs_to :survey
  has n, :answers

  def self.find_next(question_id)
    question = Question.get(question_id)
    Question.first(id: question_id + 1, survey: question.survey)
  end
end
