class Gene

  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  attr_accessor :linked_genes

  def initialize(gene_id = "AT0G00000", gene_name = "newgene", mutant_phenotype = "Description")
    @linked_genes = []
    @gene_id = gene_id.upcase

    if gene_id =~ /AT\dG\d{5}/
      @gene_id = gene_id
    else
      abort("The gene ID should have the right format (ATxGxxxxx), where x is a number")
    end

    @gene_name = gene_name
    @mutant_phenotype = mutant_phenotype.gsub("\n", '')
  end

  def add_linked_gene(gene)
    @linked_genes.append(gene)
  end

  def print()
    if @linked_genes.length > 0
      linked = ''
      @linked_genes.each {|gene| linked += "#{gene.gene_name} (#{gene.gene_id}), "}
      linked = linked.delete_suffix!(', ')
      puts "Gene #{@gene_name} (#{@gene_id}) ==> #{@mutant_phenotype} and is linked to #{linked}"
    else
      puts "Gene #{@gene_name} (#{@gene_id}) ==> #{@mutant_phenotype}"
    end
  end


end