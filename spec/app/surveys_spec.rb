require_relative '../spec_helper'

describe 'GET /surveys/voice' do
  it 'returns TwiML' do
    survey = Survey.first

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

describe 'GET /surveys/sms' do
  before :each do
    clear_cookies
  end

  context 'when receiving a user first sms' do
    before do
      question = Question.get(1)

      expect(Digest::SHA1).to receive(:hexdigest)
        .with('S23344444')
        .once
        .and_return('32746274682876424876487')

      expect(TwimlGenerator).to receive(:generate_for_sms_question)
        .with(question, hash_including(first_time: true))
        .once
        .and_return('TwiML')

      get '/surveys/sms', Body: 'survey', SmsSid: 'S23344444', From: '+4555555'
    end

    it 'responds with a cookie referencing the first question' do
      expect(rack_mock_session.cookie_jar['question_id']).to eq('1')
    end

    it 'responds with a cookie referencing the origin' do
      expect(rack_mock_session.cookie_jar['origin_id']).to eq('682876424')
    end

    it 'responds ok' do
      expect(last_response).to be_ok
      expect(last_response.body).to eq('TwiML')
    end
  end

  context 'when receiving a user sms for the a particular question' do
    before do
      question = Question.get(2)

      set_cookie 'question_id=1'
      set_cookie 'origin_id=682876424'

      answer_double = double(:answer)

      expect(Answer).to receive(:create)
        .with(hash_including(
                digits: '2',
                origin_id: '682876424',
                from: '+4555555',
                question_id: 1))
        .and_return(answer_double)

      expect(Question).to receive(:find_next)
        .with(1)
        .and_return(question)

      expect(TwimlGenerator).to receive(:generate_for_sms_question)
        .with(question, hash_including(first_time: false))
        .once
        .and_return('TwiML')

      get '/surveys/sms', Body: '2', SmsSid: 'S23344444', From: '+4555555'
    end

    it 'responds with a cookie referencing the second question' do
      expect(rack_mock_session.cookie_jar['question_id']).to eq('2')
    end

    it 'responds with a cookie referencing the origin' do
      expect(rack_mock_session.cookie_jar['origin_id']).to eq('682876424')
    end

    it 'responds ok' do
      expect(last_response).to be_ok
      expect(last_response.body).to eq('TwiML')
    end
  end

  context 'while receiving a user sms for the last question' do
    before do
      set_cookie 'question_id=4'
      set_cookie 'origin_id=682876424'

      answer_double = double(:answer)

      expect(Answer).to receive(:create)
        .with(hash_including(
                digits: '5',
                origin_id: '682876424',
                from: '+4555555',
                question_id: 4))
        .and_return(answer_double)

      expect(Question).to receive(:find_next)
        .with(4)
        .and_return(nil)

      expect(TwimlGenerator).to receive(:generate_for_sms_question)
        .with(nil, hash_including(first_time: false))
        .once
        .and_return('TwiML')

      get '/surveys/sms', Body: '5', SmsSid: 'S23344444', From: '+4555555'
    end

    it 'responds with a cookie without question reference' do
      expect(rack_mock_session.cookie_jar['question_id']).to eq('')
    end

    it 'responds with a cookie referencing the origin' do
      expect(rack_mock_session.cookie_jar['origin_id']).to eq('682876424')
    end

    it 'responds ok' do
      expect(last_response).to be_ok
      expect(last_response.body).to eq('TwiML')
    end
  end
end

describe 'GET /surveys/results' do
  it 'renders the proper view containing answer related content' do
    Answer.create(
      digits: '1',
      origin_id: 'CS999999',
      from: '99999999',
      question_id: 1
    )

    get '/surveys/results'

    expect(last_response).to be_ok
    expect(last_response.body).to include 'CS99999'
  end
end
