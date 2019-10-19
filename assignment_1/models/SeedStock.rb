require_relative 'Gene'
class SeedStock

  attr_accessor :seed_stock
  attr_accessor :gene # Type Gene
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining

  def initialize(seed_stock, mutant_gene_id, last_planted, storage, grams_remaining)
    @seed_stock = seed_stock
    @gene = mutant_gene_id
    @last_planted = last_planted
    @storage = storage
    @grams_remaining = grams_remaining.to_i
  end

  def print
    puts "\tSeedStock #{@seed_stock} with mutant gene #{@gene.gene_name}, last planted #{@last_planted},storage #{@storage}, grams remaining #{@grams_remaining}"
  end

  def extract_grams(value = 1, date = @last_planted) #plant

    #puts "-------------#{@seed_stock} had #{@grams_remaining} grams remaining-------------"

    if @grams_remaining > 0
      @grams_remaining -= value
      if @grams_remaining < 0
        @grams_remaining = 0
        #puts "Only #{grams} grams of #{@seed_stock} has been removed from the stock instead of #{value}\n\n"
      # else
      #   puts "#{value} grams of #{@seed_stock} has been removed from the stock"
      #   puts "Now #{@seed_stock} has #{@grams_remaining} grams remaining\n\n"
      end
      @last_planted = date
    end

    if @grams_remaining == 0
      puts "\tWARNING: we have run out of Seed Stock #{@seed_stock}"
      #else
      #puts "#{@seed_stock}  ==> #{@grams_remaining} remaining"
    end
  end

  def add_grams(value = 1) #plant
    @grams_remaining += value
  end

end