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
end
