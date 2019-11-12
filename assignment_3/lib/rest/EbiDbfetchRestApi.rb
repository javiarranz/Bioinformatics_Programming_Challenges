require 'rest-client'
require 'json'

class EbiDbfetchRestApi
  attr_reader :url

  def initialize()
    @url = "http://www.ebi.ac.uk/Tools/dbfetch/"
  end

  def get(db, format, id, style)
    final_url = generate_query_params(db, format, id, style)
    # puts final_url
    body = false # We are returning 'False', and we will check that with an \"if\" statement in our main code
    begin
      response = RestClient.get(final_url)
      check_response(response)
      #puts response
      body = response.body
      puts body
    rescue RestClient::ExceptionWithResponse => e
      $stderr.puts e.response
    rescue RestClient::Exception => e
      $stderr.puts e.response
    rescue Exception => e
      $stderr.puts e
    end
    body
  end

  private

  def generate_query_params(db = NIL, format = NIL, id = NIL, style = NIL)
    dbfetch_url = 'dbfetch?'
    query_params = []
    if db
      query_params.push("db=#{db}")
    end
    if format
      query_params.push("format=#{format}")
    end
    if id
      query_params.push("id=#{id}")
    end
    if style
      query_params.push("style=#{style}")
    end
    if query_params.length > 0
      @url + dbfetch_url + query_params.join("&")
    else
      raise('Missing params for EBI DBFetch Database')
    end
  end

  def check_response(response)
    # Control Api Errors
    if response.code != 200 || response.body.start_with?("ERROR")
      raise("API Error with code #{response.code} ==> #{response.body}")
    end
  end
end