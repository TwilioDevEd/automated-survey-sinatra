require_relative '../spec_helper'

describe Question do
  describe '.find_next' do
    context 'when there are questions to fill up in the survey' do
      it "returns the next question's answer" do
        next_question = Question.find_next(1)
        expect(next_question.body).to include('0 to 9')
      end
    end
    context 'when there are no more questions in the survey' do
      it 'returns nil' do
        next_question = Question.find_next(4)
        expect(next_question).to be_nil
      end
    end
  end
end
