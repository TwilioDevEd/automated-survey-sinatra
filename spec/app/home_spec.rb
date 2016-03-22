require_relative '../spec_helper'

describe 'GET /' do
  it 'renders' do
    get '/'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Call 201.897.2682 To take a survey.')
  end
end
