require 'rest-client'

class EbiDbfetchApi
  attr_reader :url

  def initialize()
    @url = "http://www.ebi.ac.uk/Tools/dbfetch/"
  end

  def get(db, format, id, style)
    final_url = generate_dbfetch_url(db, format, id, style)
    response = RestClient.get(final_url)
    check_response(response)
    puts response

    response.body
  end

  private

  def generate_dbfetch_url(db = NIL, format = NIL, id = NIL, style = NIL)
    dbfetch_url = 'dbfetch?'
    query_params = []
    if db
      query_params.append("db=#{db}")
    end
    if format
      query_params.append("format=#{format}")
    end
    if id
      query_params.append("id=#{id}")
    end
    if style
      query_params.append("style=#{style}")
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