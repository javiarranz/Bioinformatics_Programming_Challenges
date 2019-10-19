require "csv"

class File_Parser

  attr_accessor :path
  attr_accessor :file_name
  attr_accessor :content
  attr_accessor :rows

  def initialize(path, file_name, parse = true)
    @path = path
    @file_name = file_name

    # puts "Parsing: #{file_name}"
    #
    if parse
      # @content = parse_content()
      @rows = parse()
    end
  end

  def save_file(rows)
    rows.each do |row|
      File.open(@path + '/new/' + @file_name, 'w', col_sep: "\t") do |new_csv|
        new_csv.write(rows) { |csv| csv << CSV.generate_line(row) }.join("")
        # #new_csv << row + line.join("\t")

      end
    end
  end


  private # Private functions

  def parse_content()
    begin # "try" block
      return CSV.read(@path + '/' + @file_name, {:col_sep => "\t"})
    rescue => error # optionally: `rescue Exception => ex`
      puts "Error parsing : #{@path + '/' + @file_name} with error: #{error}"
    end
  end

  def parse()
    rows = []
    open(@path + '/' + @file_name) do |f|
      headers = f.gets.strip.split("\t")
      f.each do |line|
        rows.push(Hash[headers.zip(line.split("\t"))])
        # yield fields
      end
    end
    rows
  end

end