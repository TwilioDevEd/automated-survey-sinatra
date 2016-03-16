require_relative '../spec_helper'

describe 'GET /surveys/call' do
  it "should call TwimlGenerator.generate_for_incoming_call and " do
    survey = Survey.first()

    allow(RequestHelper).to receive(:base_url)
      .with(anything)
      .and_return('http://example.com')

    expect(TwimlGenerator).to receive(:generate_for_incoming_call)
      .with(survey, 'http://example.com')
      .once
      .and_return('TwiML')

    get '/surveys/call'
    expect(last_response).to be_ok
    expect(last_response.body).to include('TwiML')
  end
end
