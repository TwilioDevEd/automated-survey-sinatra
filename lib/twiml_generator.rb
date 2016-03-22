module TwimlGenerator
  def self.generate_for_incoming_call(survey, base_url)
    welcome_message = "Thank you for taking the #{survey.title} survey"
    redirect_url = "#{base_url}/questions/1"

    Twilio::TwiML::Response.new do |r|
      r.Say welcome_message
      r.Redirect redirect_url, method: 'get'
    end.to_xml
  end

  def self.generate_for_voice_question(question)
    action_url = "/questions/#{question.id}/answers"

    Twilio::TwiML::Response.new do |r|
      r.Say question.body
      r.Say QuestionMessages.message_for(question.question_type)
      if question.voice?
        r.Record action: action_url, method: 'post'
      else
        r.Gather action: action_url, method: 'post'
      end
    end.to_xml
  end

  def self.generate_for_exit
    Twilio::TwiML::Response.new do |r|
      r.Say 'Thanks for your time. Good bye'
      r.Hangup
    end.to_xml
  end

  def self.generate_for_sms_question(question, hash = {})
    if question.nil?
      return respond_sms('Thank you for taking this survey. Goodbye!')
    end

    msg = ''
    msg << 'Thank you for taking our survey!' if hash[:first_time]
    msg << question.body
    msg << "Type '1' or '0'." if question.yes_no?
    respond_sms(msg)
  end

  def self.respond_sms(message)
    Twilio::TwiML::Response.new do |r|
      r.Message message
    end.to_xml
  end

  private_class_method :respond_sms

  module QuestionMessages
    def self.message_for(type)
      {
        yesno: 'Please press the 1 for yes and the 0 for no and then hit the pound sign',
        voice: 'Please record your answer after the beep and then hit the pound sign',
        numeric: 'Please press a number between 0 and 9 and then hit the pound sign'
      }.fetch(type)
    end
  end
end
