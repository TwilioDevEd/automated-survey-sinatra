require_relative '../spec_helper'


describe 'GET /surveys/call' do

  it "should call TwimlGenerator.generate_for_incoming_call and " do
    survey_double =  double(:survey)
    expect(survey_double).to receive(:title).and_return('FIRST')

    expect(TwimlGenerator).to receive(:generate_for_incoming_call)
      .with(survey_double, 'http://example.com')
      .once
      .and_return('TwiML')

    get '/surveys/call'
    expect(last_response).to be_ok
    expect(last_response.body).to include('TwiML')
  end
end
