require 'rest-client'
require 'json'

class PsiquicApi
  attr_reader :url

  def initialize()
    @url = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/"
  end

  def get(db, format, id, style)
    final_url = generate_dbfetch_url(db, format, id, style)
    response = RestClient.get(final_url)
    check_response(response)
    puts response

    response.body
  end

  private
#TODO FINISH THE URL
  def generate_dbfetch_url(version = 'current/', db = NIL, ids = NIL,  field = NIL, style = NIL)
    dbfetch_url = version + "search/query/"
    query_params = []
    if db
      query_params.append("db=#{db}")
    end
    if ids
      query_params.append("id=#{id}")
    end
    if field
      query_params.append("format=#{format}.")
    end
    if style
      query_params.append("style=#{style}")
    end
    if query_params.length > 0
      @url + dbfetch_url + query_params.join("/")
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