class Gene

  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype

  def initialize(gene_id = "AT0G00000", gene_name = "newgene", mutant_phenotype = "Description")
    @gene_id = gene_id

    if gene_id =~ /A[Tt]\d[Gg]\d\d\d\d\d/
      @gene_id = gene_id
    else
      abort("The gene ID should have the right format (ATxGxxxxx), where x is a number")
    end

    @gene_name = gene_name
    @mutant_phenotype = mutant_phenotype
  end

  def print
    puts "Gene #{@gene_name} (#{@gene_id}) ==> #{@mutant_phenotype}"
  end


end