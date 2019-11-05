require 'rest-client'

class RestApiAbstract

  attr_reader :url

  def get_response(url)
    body = false
    begin
      response = RestClient.get(url)
      check_response(response)
      puts response
      body = response.body
    rescue RestClient::ExceptionWithResponse => e
      $stderr.puts e.response
        # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    rescue RestClient::Exception => e
      $stderr.puts e.response
        # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    rescue Exception => e
      $stderr.puts e
      # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    end
    body
  end
end