class Gene

  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :protein
  attr_accessor :mutant_phenotype
  attr_accessor :linked_genes
  attr_accessor :go_list
  attr_accessor :kegg_list

  def initialize(gene_id = "AT0G00000", gene_name = "", mutant_phenotype = "")

    gene_id = gene_id.upcase
    gene_id = gene_id.gsub("\n", '')
    gene_name = gene_name.gsub("\n", '')
    mutant_phenotype = mutant_phenotype.gsub("\n", '')

    if gene_id =~ /^AT\dG\d{5}$/
      @gene_id = gene_id
    else
      raise("The gene ID should have the right format (ATxGxxxxx), where x is a number. Value provided: #{gene_id}")
    end
    if gene_name != ""
      @gene_name = gene_name
    else
      @gene_name = @gene_id
    end
    @mutant_phenotype = mutant_phenotype

    @linked_genes = []
    @go_list = []
    @kegg_list = []
    @protein = nil
  end

  def add_linked_gene(gene)
    @linked_genes.append(gene)
  end

  def print()
    message = "\tGene "

    if @gene_name != @gene_id
      message += "#{@gene_name} (#{@gene_id})"
    else
      message += "#{@gene_name}"
    end

    if @mutant_phenotype != ""
      message += "==> #{@mutant_phenotype}"
    end

    if @linked_genes.length > 0
      linked = ''
      @linked_genes.each {|gene| linked += "#{gene.gene_name} (#{gene.gene_id}), "}
      linked = linked.delete_suffix!(', ')
      message += " and is linked to #{linked}"
    end
    puts message
  end

  def add_go(go)
    go_list.append(go)
  end

  def add_kegg(kegg)
    kegg_list.append(kegg)
  end

end

# CLASS PROTEIN TO STORE THE INFORMATION OF EACH PROTEIN
# linked genes and print functions ARE NOT USED HERE!!
# this functions were imported from last exercise and
# I decided not tu delete them in case I need them in the future