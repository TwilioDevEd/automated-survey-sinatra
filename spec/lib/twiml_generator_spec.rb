require 'nokogiri'
require_relative '../spec_helper'
require_relative '../../lib/twiml_generator'

describe TwimlGenerator do
  describe '.generate_for_incoming_call' do
    it 'generates twiml with say and play nodes' do
      survey_double =  double(:survey)
      expect(survey_double).to receive(:title).and_return('FIRST')

      xml_string = described_class
        .generate_for_incoming_call(survey_double, 'http://example.com')

      document = Nokogiri::XML(xml_string)
      nodes = document.root.children

      expect(nodes[0].name).to eq('Say')
      expect(nodes[0].content)
        .to eq('Thank you for taking the FIRST survey')
      expect(nodes[1].name).to eq('Redirect')
      expect(nodes[1].content)
        .to eq('http://example.com/questions/find/1')
    end
  end
end
