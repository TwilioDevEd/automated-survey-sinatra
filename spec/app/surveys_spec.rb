require_relative '../spec_helper'

describe 'GET /surveys/voice' do
  it "should call TwimlGenerator.generate_for_incoming_call and return TwiML" do
    survey = Survey.first()

    allow(RequestHelper).to receive(:base_url)
      .with(anything)
      .and_return('http://example.com')

    expect(TwimlGenerator).to receive(:generate_for_incoming_call)
      .with(survey, 'http://example.com')
      .once
      .and_return('TwiML')

    get '/surveys/voice'
    expect(last_response).to be_ok
    expect(last_response.body).to include('TwiML')
  end
end

describe 'GET /surveys/results' do
  it "should render the proper view containing answer related content" do
    answer = Answer.create(
      digits: '1',
      call_sid: 'CS999999',
      from: '99999999',
      question_id: 1
    )
    answer.save!

    get '/surveys/results'
    expect(last_response).to be_ok
    expect(last_response.body).to include 'CS99999'
  end
end
