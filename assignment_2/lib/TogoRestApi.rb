require 'rest-client'
require 'json'

class TogoRestApi
  attr_reader :url

  def initialize()
    @url = "http://togows.dbcls.jp/"
  end

  def get(db, format, id, style)
    final_url = generate_dbfetch_url(db, format, id, style)
    response = RestClient.get(final_url)
    check_response(response)
    puts response

    response.body
  end

  private
#TODO FINISH TOGO URL
  def generate_dbfetch_url(db = NIL, ids = NIL,  field = NIL, format = NIL)
    dbfetch_url = 'entry/'
    query_params = []
    if db
      query_params.append("#{db}/")
    end
    if ids
      query_params.append("#{ids}/")
    end
    if field
      query_params.append("#{field}")
    end
    if style
      query_params.append(".#{format}")
    end
    if query_params.length > 0
      @url + dbfetch_url + query_params.join()
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