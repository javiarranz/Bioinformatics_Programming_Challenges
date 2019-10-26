require './assignment_2/lib/SqlLite'


class GeneDatabase

  attr_accessor :genes_list

  def initialize()
    @sqllite = SqlLite.new
    puts "...Initiliazing Gene Database => Done"
    @geneTable = "Gene"
    @geneLinkedTable = "Linked_Genes"
    @genes_list = []
  end

  def add_gene(gene)
    # @genes_list.append(gene)
    # TODO change this to ORM to prevent SQL Injection
    query = "INSERT INTO #{@geneTable} VALUES ('#{gene.gene_id}','#{gene.gene_name}')"
    @sqllite.execute(query)

  end

  def get_gene(gene_id)
    # TODO get from Database and create the Gene
    # query = "SELECT * FROM #{@geneTable} WHERE id = '#{gene_id}'"
    # n_gene = @sqllite.execute(query) #GEne(..id..,...,..)

    # query = "SELECT * FROM #{@geneLinkedTable} WHERE gene_id_1 = '#{gene_id}'"
    # linked_gene = @sqllite.execute(query)
    #
    # Iterate linked genes, get gene_2
    #
    # query = "SELECT * FROM #{@geneTable} WHERE id = '#{gene_2}'"
    # n_gene_2 = @sqllite.execute(query) #GEne(..id..,...,..)
    #
    # GEne_1. add_linked
    #
    #
    @genes_list.each do |gene|
      if gene.gene_id == gene_id
        return gene
      end
    end
  end

  def link_gene(gene_id_1, gene_id_2)
    # TODO get from Database and create the Gene
    query = "INSERT INTO #{@geneTable} VALUES ('#{gene_id_1}','#{gene_id_2}')"
    @sqllite.execute(query)
  end

  def print()
    puts "\t------------Genes Table------------"
    @genes_list.each { |gene| gene.print() }
  end
end