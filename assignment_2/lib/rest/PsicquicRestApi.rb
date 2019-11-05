require 'rest-client'
require 'json'
require 'active_support/core_ext/hash'

class PsicquicRestApi
  attr_reader :url

  def initialize()
    @url = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices"
  end

  def get(id, format)
    final_url = generate_url('current', id) + generate_query_params(format)
    body = false
    begin
      response = RestClient.get(final_url)
      check_response(response)
      body = parse_format(format, response.body)
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

  private

  def parse_format(format, content)
    parsed_content = false
    case format
    when 'xml25'
      data = Hash.from_xml(content)
      if data['entrySet']['entry']
        parsed_content = data['entrySet']['entry']
      end
    when 'tab25'
      if content != ""
        parsed_content = content
      end
    end
    parsed_content
  end

  def generate_url(version = 'current', id = NIL)
    fetch_url = "#{@url}/#{version}/search/query/"
    if id
      fetch_url += id
    else
      raise('Missing id for Psicquic')
    end
    fetch_url
  end


  def generate_query_params(format = NIL)
    f = ""
    if format
      f = "?format=#{format}"
    end
    f
  end

  def check_response(response)
    # Control Api Errors
    if response.code != 200 || response.body.start_with?("ERROR")
      raise("API Error with code #{response.code} ==> #{response.body}")
    end
  end
end