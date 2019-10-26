require 'sqlite3'

class SqlLite
  attr_reader :db

  def initialize()
    @db = SQLite3::Database.open "biology.db"

  end

  def execute(query)
    begin
      @db.execute query
    rescue SQLite3::Exception => e
      puts "Cannot execute query #{query} ===> #{e}"
    end
  end
end