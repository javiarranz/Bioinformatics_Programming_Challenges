require './assignment_2/lib/SqlLite'


class GeneDatabase

  attr_accessor :genes_list

  def initialize()
    @sqllite = SqlLite.new
    puts "...Initiliazing Gene Database => Done"
    @geneTable = "Gene"
    @geneLinkedTable = "Linked_Genes"
    # @genes_list = []
  end

  def clean_tables(geneTable = true, linked_table = true)

    if geneTable
      delete_table(@geneTable)
    end
    if linked_table
      delete_table(@geneLinkedTable)
    end
  end

  def add_gene(gene_id, gene_name = '', mutant_phenotype = '')

    # TODO change this to ORM to prevent SQL Injection
    begin
      gene = Gene.new(gene_id, gene_name, mutant_phenotype) #Create Gene class to validate the input data
    rescue Exception => e
      puts "Cannot insert #{gene_id} because it is not in compliant with the Gene rules. #{e}"
    end
    begin
      # Inserta en base de datos
      query = "INSERT INTO #{@geneTable} VALUES ('#{gene.gene_id}','#{gene.gene_name}','#{gene.mutant_phenotype}')"
      @sqllite.execute(query)
      gene
    rescue SQLite3::Exception => e
    end
  end

  def delete_gene(gene_id)
    # TODO change this to ORM to prevent SQL Injection
    query = "DELETE from #{@geneTable} WHERE id = #{gene_id}"
    @sqllite.execute(query)
  end

  def get_all_genes_without_linked()
    query = "SELECT * FROM #{@geneTable}"
    n_gene = @sqllite.execute(query)
    genes = []
    n_gene.each do |gene|
      genes.push(Gene.new(gene[0], gene[1], gene[2]))
    end
    genes
  end

  def get_gene(gene_id)
    gene = get_single_gen(gene_id)

    query = "SELECT * FROM #{@geneLinkedTable} WHERE gene_id_1 = '#{gene_id}'"
    linked_gene = @sqllite.execute(query)

    # Iterate linked genes, get gene_2
    linked_gene.each do |gene_linked_data|
      gene_linked = get_single_gen(gene_linked_data[1])
      gene.add_linked_gene(gene_linked)
    end
    gene
  end

  def link_gene(gene_id_1, gene_id_2)
    # TODO get from Database and create the Gene
    query = "INSERT INTO #{@geneTable} VALUES ('#{gene_id_1}','#{gene_id_2}')"
    @sqllite.execute(query)
  end

  def print()
    puts "\t------------Genes Table------------"
    @genes_list.each {|gene| gene.print()}
  end


  private

  def get_single_gen(gene_id)
    query = "SELECT * FROM #{@geneTable} WHERE id = '#{gene_id}'"

    db_gene = @sqllite.execute(query)
    db_gene = db_gene[0]
    Gene.new(db_gene[0], db_gene[1], db_gene[2])
  end

  def delete_table(table)
    query = "DELETE FROM #{table}"
    @sqllite.execute(query)
  end
end