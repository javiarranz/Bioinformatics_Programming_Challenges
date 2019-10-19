class GeneDatabase

  attr_accessor :genes_list

  def initialize()
   puts "...Initiliazing Gene Database => Done"
   @genes_list = []
  end

  def add_gene(gene)
    @genes_list.append(gene)
  end

  def get_gene(gene_id)
    @genes_list.each do |gene|
      if gene.gene_id == gene_id
        return gene
      end
    end
  end

  def print()
    puts "\t------------Genes Table------------"
    @genes_list.each { |gene| gene.print() }
  end
end