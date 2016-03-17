require_relative '../spec_helper'

describe Question do
  describe '.find_next' do
    it "gets the next question's answer" do

      next_question = Question.find_next(1)
      expect(next_question.body).to include('0 to 9')
    end
  end
end
