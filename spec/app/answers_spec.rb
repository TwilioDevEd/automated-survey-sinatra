require_relative '../spec_helper'

describe 'POST /questions/:question_id/answers' do
  context 'while there is still questions in the survey' do
    it "should create a new answer and return TwiML for the second question" do
      answer = Answer.new(
        recording_url: 'http://example.com',
        digits: '1',
        call_sid: 'CS2222',
        from: '5555555',
        question_id: 1
      )
      question = Question.get(2)

      expect(Answer).to receive(:create)
        .with(hash_including(
          recording_url: 'http://example.com',
          digits: '1',
          call_sid: 'CS2222',
          from: '5555555',
          question_id: 1))
        .and_return(answer)

      expect(Question).to receive(:find_next)
        .with(1)
        .and_return(question)

      expect(TwimlGenerator).to receive(:generate_for_question)
        .once
        .and_return('TwiML')

      post '/questions/1/answers', recording_url: 'http://example.com', digits: '1',
        call_sid: 'CS2222', from: '5555555'

      expect(last_response).to be_ok
      expect(last_response.body).to include('TwiML')
    end
  end

  context "while there there isn't questions in the survey" do
    it "should create a new answer and return TwiML for exiting the survey" do
      answer = Answer.new(
        recording_url: 'http://example.com',
        digits: '1',
        call_sid: 'CS2222',
        from: '5555555',
        question_id: 4
      )

      expect(Answer).to receive(:create)
        .with(hash_including(
          recording_url: 'http://example.com',
          digits: '1',
          call_sid: 'CS2222',
          from: '5555555',
          question_id: 4))
        .and_return(answer)

      expect(Question).to receive(:find_next)
        .with(4)
        .and_return(nil)

      expect(TwimlGenerator).to receive(:generate_for_exit)
        .once
        .and_return('TwiML')

      post '/questions/4/answers', recording_url: 'http://example.com', digits: '1',
        call_sid: 'CS2222', from: '5555555'

      expect(last_response).to be_ok
      expect(last_response.body).to include('TwiML')
    end
  end
end
