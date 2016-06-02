# Automated Suvey with Twilio, Ruby and Sinatra

[![Build Status](https://travis-ci.org/TwilioDevEd/automated-survey-sinatra.svg?branch=master)](https://travis-ci.org/TwilioDevEd/automated-survey-sinatra)

Use Twilio to conduct automated phone surveys.

## Run the application

1. Clone the repository and `cd` into it

   ```bash
   $ git clone git@github.com:TwilioDevEd/automated-survey-sinatra.git
   $ cd  automated-survey-sinatra
   ```

1. Install the application dependencies

    ```bash
    $ bundle install
    ```

1. Create development and test databases

   _Make sure you have installed [PostgreSQL](http://www.postgresql.org/). If on
   a Mac, I recommend [Postgres.app](http://postgresapp.com)_.

   ```bash
   $ createdb automated_survey_sinatra
   $ createdb automated_survey_sinatra_test
   ```

1. Make sure the tests succeed

   ```bash
   $ bundle exec rspec
   ```

1. Start the development server

   ```bash
   $ bundle exec rakeup
   ```

1. Check it out at [`http://localhost:9292`](http://localhost:9292)

1. Expose your application to the wider internet using [ngrok](http://ngrok.com). This step
  is important because the application won't work as expected if you run it through
  localhost.

  ```bash
  $ ngrok http 9292
  ```

  Once ngrok is running, open up your browser and go to your ngrok URL. It will
  look something like this: `http://9a159ccf.ngrok.io`

  You can read [this blog post](https://www.twilio.com/blog/2015/09/6-awesome-reasons-to-use-ngrok-when-testing-webhooks.html)
  for more details on how to use ngrok.

1. Configure Twilio to call your webhooks

  You will also need to configure Twilio to call your application when calls are received on your **Twilio Number**. The Voice url should look something like this:

  ```
  http://9a159ccf.ngrok.io/conference/surveys/voice
  ```

  And the SMS one like this:

  ```
  http://9a159ccf.ngrok.io/conference/surveys/sms
  ```

  ![Configure Voice](http://howtodocs.s3.amazonaws.com/twilio-number-config-all-med.gif)

That's it!

## Meta

* No warranty expressed or implied. Software is as is. Diggity.
* [MIT License](http://www.opensource.org/licenses/mit-license.html)
* Lovingly crafted by Twilio Developer Education.
