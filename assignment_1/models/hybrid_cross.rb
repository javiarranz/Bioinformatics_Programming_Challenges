require_relative 'seed_stock'
require_relative 'gene'

class HybridCross

  attr_accessor :parent1 #Type Seed Stock
  attr_accessor :parent2 #Type Seed Stock
  attr_accessor :f2_wild
  attr_accessor :f2_p1
  attr_accessor :f2_p2
  attr_accessor :f2_p1p2

  def initialize(parent1, parent2, f2_wild, f2_p1, f2_p2, f2_p1p2)
    @parent1 = parent1
    @parent2 = parent2
    @f2_wild = f2_wild.to_i
    @f2_p1 = f2_p1.to_i
    @f2_p2 = f2_p2.to_i
    @f2_p1p2 = f2_p1p2.to_i
  end


  def print
    puts "Hybrid Cross Parent 1: #{@parent1.seed_stock}, Parent 2: #{@parent2.seed_stock}, f2_wild: #{@f2_wild}, f2_p1: #{@f2_p1}, f2_p2: #{@f2_p2}, f2_p1p2: #{@f2_p1p2}"
  end


  def chi_square()
    #Sumatorio(observados-esperados)^2/esperados

    total = @f2_wild + @f2_p1 + @f2_p2 + @f2_p1p2
    cq1 = (total * 9.0) / 16.0
    cq2 = (total * 3.0) / 16.0
    cq3 = (total * 3.0) / 16.0
    cq4 = total / 16.0

    chi_square = (((@f2_wild - cq1) ** 2) / cq1 + ((@f2_p1 - cq2) ** 2) / cq2 + ((@f2_p2 - cq3) ** 2) / cq3 + ((@f2_p1p2 - cq4) ** 2) / cq4).to_f

    puts "Chi_square for [#{@parent1.seed_stock}, #{@parent2.seed_stock}] ==> #{chi_square}"

    if chi_square >= 3.84 # This is the value that tell us if the genes are linked or not

      puts "*\t=========> MATCH!"
      puts "*\t=========> Recording: #{@parent1.gene.to_s} is genetically linked to #{@parent2.gene.to_s} with chisquare score #{chi_square}"

      @parent1.gene.add_linked_gene(@parent2.gene)
      @parent2.gene.add_linked_gene(@parent1.gene)

      @parent1.gene.print(true)
      @parent2.gene.print(true)
      #cross.@seed_stock.parent1.chi_square = cross.parent2.gene_name
      # We change the 'linked' property of the instance ('linked' = instance of the gene to which is linked)
      #cross.parent2.gene.gene_name.chi_square = cross.parent1.gene_name
      # Do the same thing in the linked gene
    end
  end


end