module TwimlGenerator
  def self.generate_for_incoming_call(survey, base_url)
    welcome_message = "Thank you for taking the #{survey.title} survey"
    redirect_url = "#{base_url}/questions/find/1"

    Twilio::TwiML::Response.new do |r|
      r.Say welcome_message
      r.Redirect redirect_url
    end.to_xml
  end
end
