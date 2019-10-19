class SeedDatabase

  attr_accessor :seed_list

  def initialize()

    puts "Initiliazing Seed Database"
    @seed_list = []
  end

  def add_seed(seed)
    @seed_list.append(seed)
  end

  def get_seed(seed_name)
    @seed_list.each do |seed|
      if seed.seed_stock == seed_name
        return seed
      end
    end
  end

  def print()
    puts "\n\n------------Seed Table------------"
    @seed_list.each { |seed| seed.print() }
  end

  def extract_grams(value, date, seed_id=nil)
    if seed_id
      puts seed_id
    else
      #TODO print seed_list before
      @seed_list.each do |seed|
        seed.extract_grams(7, "24/10/2019")
        #new_seed_rows.push([seed.seed_stock, seed.gene.gene_id, seed.last_planted, seed.storage, seed.grams_remaining])
      end
      #TODO print seed_list after
    end

  end

  def seed_list_serializer()
    list = []
    @seed_list.each do |seed|
      list.append(seed.get_serializer())
    end
  end
end