module TwimlGenerator
  def self.generate_for_incoming_call(survey, base_url)
    welcome_message = "Thank you for taking the #{survey.title} survey"
    redirect_url = "#{base_url}/questions/1"

    response = Twilio::TwiML::VoiceResponse.new
    response.say welcome_message
    response.redirect redirect_url, method: 'get'

    response.to_xml_str
  end

  def self.generate_for_voice_question(question)
    action_url = "/questions/#{question.id}/answers"

    response = Twilio::TwiML::VoiceResponse.new
    response.say question.body
    response.say QuestionMessages.message_for(question.question_type)
    if question.voice?
      response.record action: action_url, method: 'post'
    else
      response.gather action: action_url, method: 'post'
    end

    response.to_xml_str
  end

  def self.generate_for_exit
    response = Twilio::TwiML::VoiceResponse.new
    response.say 'Thanks for your time. Good bye'
    response.hangup

    response.to_xml_str
  end

  def self.generate_for_sms_question(question, hash = {})
    if question.nil?
      return respond_sms('Thank you for taking this survey. Goodbye!')
    end

    msg = ''
    msg << 'Thank you for taking our survey!' if hash[:first_time]
    msg << question.body
    msg << QuestionMessages.message_for(:yesno_sms) if question.yes_no?
    respond_sms(msg)
  end

  def self.respond_sms(message)
    response = Twilio::TwiML::MessagingResponse.new
    response.message message

    response.to_xml_str
  end

  private_class_method :respond_sms

  module QuestionMessages
    def self.message_for(type)
      {
        yesno: 'Please press the 1 for yes and the 0 for no and then hit the pound sign',
        voice: 'Please record your answer after the beep and then hit the pound sign',
        numeric: 'Please press a number between 0 and 9 and then hit the pound sign',
        yesno_sms: " Type '1' or '0'."
      }.fetch(type)
    end
  end
end
