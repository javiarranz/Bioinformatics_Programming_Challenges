require_relative 'seed_stock'
require_relative 'gene'

class Hybrid_Cross

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
    puts "Hybrid Cross Parent 1: #{@parent1}, Parent 2: #{@parent2}, f2_wild: #{@f2_wild}, f2_p1: #{@f2_p1}, f2_p2: #{@f2_p2}, f2_p1p2: #{@f2_p1p2}"
  end


  def chi_square(cross)
    #Sumatorio(observados-esperados)^2/esperados

    total = cross.f2_wild + cross.f2_p1 + cross.f2_p2 + cross.f2_p1p2

    cq1 = ((total * 9) / 16).to_f
    cq2 = ((total * 3) / 16).to_f
    cq3 = ((total * 3) / 16).to_f
    cq4 = ((total) / 16).to_f

    chi_square = (((cross.f2_wild - cq1) ** 2) / cq1 + ((cross.f2_p1 - cq2) ** 2) / cq2 + ((cross.f2_p2 - cq3) ** 2) / cq3 + ((cross.f2_p1p2 - cq4) ** 2) / cq4).to_f

    puts "Chi_square for [#{parent1}, #{parent2}] ==> #{chi_square}"

    if chi_square >= 3.84 # This is the value that tell us if the genes are linked or not

      puts "*\t=========> MATCH!"
      puts "*\t=========> Recording: #{cross.parent1.to_s} is genetically linked to #{cross.parent2.to_s} with chisquare score #{chi_square}"

      #cross.@seed_stock.parent1.chi_square = cross.parent2.gene_name
      # We change the 'linked' property of the instance ('linked' = instance of the gene to which is linked)
      #cross.parent2.gene.gene_name.chi_square = cross.parent1.gene_name
      # Do the same thing in the linked gene
    end
  end


end