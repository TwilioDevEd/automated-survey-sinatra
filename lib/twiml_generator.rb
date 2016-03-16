module TwimlGenerator
  def self.generate_for_incoming_call(survey, base_url)
    welcome_message = "Thank you for taking the #{survey.title} survey"
    redirect_url = "#{base_url}/questions/find/1"

    Twilio::TwiML::Response.new do |r|
      r.Say welcome_message
      r.Redirect redirect_url
    end.to_xml
  end

  def self.generate_for_question(question)
    action_url = "/questions/#{question.id}/answers"

    Twilio::TwiML::Response.new do |r|
      r.Say question.body
      r.Say QuestionMessages.message_from_type[question.question_type]
      if question.question_type == :voice
        r.Record action: action_url, method: 'post'
      else
        r.Gather action: action_url, method: 'post'
      end
    end.to_xml
  end

  module QuestionMessages
    def self.message_from_type
      types_messages = Hash.new
      types_messages[:yesno] = 'Please press the 1 for yes and the 0 for no and then hit the pound sign '
      types_messages[:voice] = 'Please record your answer after the beep and then hit the pound sign'
      types_messages[:numeric] = 'Please press a number between 0 and 9 and then hit the pound sign'

      types_messages
    end
  end
end
