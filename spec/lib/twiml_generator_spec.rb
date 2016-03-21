require 'nokogiri'
require_relative '../spec_helper'
require_relative '../../lib/twiml_generator'

describe TwimlGenerator do
  describe '.generate_for_incoming_call' do
    context "if question type is voice" do
      it 'should generate twiml with say and play nodes' do
        survey_double =  double(:survey)
        expect(survey_double).to receive(:title).and_return('FIRST')

        xml_string = described_class
          .generate_for_incoming_call(survey_double, 'http://example.com')

        document = Nokogiri::XML(xml_string)
        nodes = document.root.children

        expect(document.at_xpath('//Response//Say').content)
          .to eq('Thank you for taking the FIRST survey')
        expect(document.at_xpath('//Response//Redirect').content)
          .to eq('http://example.com/questions/1')
      end
    end
  end

  describe '.generate_for_voice_question' do
    context "if question type is voice" do
      it 'should generate twiml using record' do
        question = Question
          .new(id: 1, body:"How's the weather?" , question_type: :voice)

        xml_string = described_class.generate_for_voice_question(question)
        document = Nokogiri::XML(xml_string)

        expect(document.at_xpath('//Response//Say[1]').content)
          .to eq(question.body)
        expect(document.at_xpath('//Response//Say[2]').content)
          .to eq(TwimlGenerator::QuestionMessages.message_from_type[:voice])
        expect(document.at_xpath('//Response//Record/@action').content)
          .to eq("/questions/#{question.id}/answers")
      end
    end

    context "if question type is numeric or yes/no" do
      [
        {
          id: 1,
          body:'On a scale of 0 to 9 how much do you like ice cream?',
          question_type: :numeric
        },
        {
          id: 1,
          body:'Do you like my classical voice? 1 for yes and 0 for no',
          question_type: :yesno
        }
      ].each do |options|
        it 'should generate twiml using gather' do
          question = Question
            .new(id: options[:id], body: options[:body], question_type: options[:question_type])

          xml_string = described_class.generate_for_voice_question(question)
          document = Nokogiri::XML(xml_string)

          expect(document.at_xpath('//Response//Say[1]').content)
            .to eq(question.body)
          expect(document.at_xpath('//Response//Say[2]').content)
            .to eq(TwimlGenerator::QuestionMessages.message_from_type[question.question_type])
          expect(document.at_xpath('//Response//Gather/@action').content)
            .to eq("/questions/#{question.id}/answers")
        end
      end
    end
  end

  describe '.generate_for_exit' do
    it 'should generate twiml with say and hangup' do
      xml_string = described_class.generate_for_exit()

      document = Nokogiri::XML(xml_string)
      nodes = document.root.children

      expect(document.at_xpath('//Response//Say').content)
        .to eq('Thanks for your time. Good bye')
      expect(document.at_xpath('//Response//Hangup').content).to eq('')
    end
  end

  describe '.generate_for_sms_question' do
    context "with a non nil question and 'first_time' set to true" do
      it 'should generate twiml with Message and welcome message' do
        question = Question
          .new(id: 1, body:"Is weather ok?" , question_type: :yesno)

        xml_string = described_class.generate_for_sms_question(question, first_time: true)

        document = Nokogiri::XML(xml_string)
        nodes = document.root.children
        expect(document.at_xpath('//Response//Message').content)
          .to include('Thank you for taking our survey!')
      end
    end

    context "with a non nil question and 'first_time' set to false" do
      it 'should generate twiml with Message and no welcome message' do
        question = Question
          .new(id: 1, body:"How's weather?1.Bad 2.OK", question_type: :numeric)

        xml_string = described_class.generate_for_sms_question(question, first_time: false)

        document = Nokogiri::XML(xml_string)
        nodes = document.root.children
        expect(document.at_xpath('//Response//Message').content)
          .to_not include('Thank you for taking our survey!')
      end
    end

    context "with a non nil question of type 'yesno'" do
      it 'should generate twiml with Message and special instructions' do
        question = Question.new(id: 1, body:"Is weather ok?" , question_type: :yesno)

        xml_string = described_class.generate_for_sms_question(question, first_time: false)

        document = Nokogiri::XML(xml_string)
        nodes = document.root.children
        expect(document.at_xpath('//Response//Message').content)
          .to include("Type 'yes' or 'no'.")
      end
    end

    context "with a non nil question which type differs from 'yesno'" do
      it 'should generate twiml with Message and no special instructions' do
        question = Question
          .new(id: 1, body:"How's weather?1.Bad 2.OK", question_type: :numeric)

        xml_string = described_class.generate_for_sms_question(question, first_time: false)

        document = Nokogiri::XML(xml_string)
        nodes = document.root.children
        expect(document.at_xpath('//Response//Message').content)
          .to_not include("Type 'yes' or 'no'.")
      end
    end

    context "with a nil question" do
      it 'should generate twiml with Message and farewell message' do
        question = nil

        xml_string = described_class.generate_for_sms_question(question, first_time: false)

        document = Nokogiri::XML(xml_string)
        nodes = document.root.children
        expect(document.at_xpath('//Response//Message').content)
          .to include('Thank you for taking this survey. Goodbye!')
      end
    end
  end
end
