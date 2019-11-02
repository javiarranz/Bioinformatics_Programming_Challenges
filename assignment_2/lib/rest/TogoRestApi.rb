require 'rest-client'
require 'json'

class TogoRestApi
  attr_reader :url

  def initialize()
    @url = "http://togows.dbcls.jp/"
  end

  def get(db, ids, field, format)
    final_url = generate_url(db, ids, field, format)

    body = false
    begin
      response = RestClient.get(final_url)
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

  private

  def generate_url(db = NIL, ids = NIL, field = NIL, format = NIL)
    togo_url = 'entry/'
    url_slug = []
    if db
      url_slug.append("#{db}")
    end
    if ids
      url_slug.append("#{ids}")
    end
    if field
      url_slug.append("#{field}")
    end

    slug = url_slug.join("/")
    if format
      slug += ".#{format}"
    end
    if url_slug.length > 0
      @url + togo_url + slug
    else
      raise('Missing params for Togo Rest Api')
    end
  end

  def check_response(response)
    # Control Api Errors
    if response.code != 200 || response.body.start_with?("ERROR")
      raise("API Error with code #{response.code} ==> #{response.body}")
    end
  end
end