require 'data_mapper'

require_relative '../models/survey'
require_relative '../models/question'
require_relative '../models/answer'

module DataMapperHelper
  def self.setup(database_url)
    DataMapper.setup(:default, database_url)
    DataMapper.finalize

    # this section automatically creates the tables
    Survey.auto_upgrade!
    Question.auto_upgrade!
    Answer.auto_upgrade!
  end

  def self.seed_if_empty
    if Survey.all.count == 0
      survey = Survey.create(title: 'Default')

      questions = YAML.load_file('config/questions.yml')
      questions.each do |q|
        survey.questions.create(body: q['body'], question_type: q['question_type'])
      end

      survey.questions.save
    end
  end
end
