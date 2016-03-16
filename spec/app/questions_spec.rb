require_relative '../spec_helper'

describe 'GET /questions/call/1' do
  it "should call TwimlGenerator.generate_for_question and return TwiML" do
    question = Question.new(id: 1, body:"How's the weather?" , question_type: :voice)

    allow(Question).to receive(:get)
      .with(anything)
      .and_return(question)

    expect(TwimlGenerator).to receive(:generate_for_question)
      .with(question)
      .once
      .and_return('TwiML')

    get '/questions/find/1'
    expect(last_response).to be_ok
    expect(last_response.body).to include('TwiML')
  end
end
