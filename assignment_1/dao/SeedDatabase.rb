class SeedDatabase

  attr_accessor :seed_list

  def initialize()

    puts "...Initiliazing Seed Database => Done"
    @seed_list = []
  end

  def add_seed(seed)
    @seed_list.append(seed)
  end

  def get_seed_stock(seed_name)
    @seed_list.each do |seed|
      if seed.seed_stock == seed_name
        return seed
      end
    end
  end

  def print()
    puts "\t------------Seed Table------------"
    @seed_list.each { |seed| seed.print() }
  end

  def extract_grams(value, date, seed_stock = nil)
    @seed_list.each do |seed|
      if seed_stock
        if seed_stock == seed.seed_stock
          return seed.extract_grams(value, date)
        end
      else
        seed.extract_grams(value, date)
      end
    end
  end

  def seed_list_serializer()
    list = []
    @seed_list.each do |seed|
      list.append([seed.seed_stock, seed.gene.gene_id, seed.last_planted, seed.storage, seed.grams_remaining])
    end
    list
  end

  def write_database(file, headers)
    new_seed_rows = seed_list_serializer.unshift(headers)
    file.save_file(new_seed_rows)
  end
end