require './assignment_2/lib/SqlLite'
require './assignment_2/models/Gene'
require './assignment_2/models/Protein'

# This class contains all the functions that our database can do (add, get_single, get_all, delete..)


class GeneDatabase

  attr_accessor :genes_list

  def initialize()
    @sqllite = SqlLite.new
    puts "...Initiliazing Gene Database => Done"
    @geneTable = "Gene"
    @proteinTable = "Protein"
    @interactionsTable = "PPI"
    @geneLinkedTable = "Linked_Genes"
    @keggTable = "Kegg"
    @goTable = "Go"
    # @genes_list = []
  end

  def clean_tables(geneTable = true, linked_table = true, protein_table = true,
                   interactions_table = true, kegg_table = true, go_table = true)

    if geneTable
      delete_table(@geneTable)
      puts "- Deleted #{@geneTable}"
    end
    if protein_table
      delete_table(@proteinTable)
      puts "- Deleted #{@proteinTable}"
    end
    if linked_table
      delete_table(@geneLinkedTable)
      puts "- Deleted #{@geneLinkedTable}"
    end
    if interactions_table
      delete_table(@interactionsTable)
      puts "- Deleted #{@interactionsTable}"
    end
    if kegg_table
      delete_table(@keggTable)
      puts "- Deleted #{@keggTable}"
    end
    if go_table
      delete_table(@goTable)
      puts "- Deleted #{@goTable}"
    end

    puts 'Cleaned Tables'
  end

  def add_gene(gene_id, gene_name = '', mutant_phenotype = '')
    gene = get_single_gen(gene_id)
    if !gene
      begin
        gene = Gene.new(gene_id, gene_name, mutant_phenotype) #Create Gene class to validate the input data
        # Insert in database
        query = "INSERT INTO #{@geneTable} VALUES ('#{clean_value(gene.gene_id)}','#{clean_value(gene.gene_name)}','#{clean_value(gene.mutant_phenotype)}')"
        q = @sqllite.execute(query)
        return gene
      rescue Exception => e
        #puts "Cannot insert #{gene_id} because it is not in compliant with the Gene rules. #{e}"
      end
      return false
    end
    gene
  end

  def add_protein(protein_id, gene)
    protein = get_single_protein(protein_id)
    if !protein
      begin
        protein = Protein.new(protein_id, gene)
        # Insert into database
        query = "INSERT INTO #{@proteinTable} VALUES ('#{clean_value(protein.protein_id)}','#{clean_value(gene.gene_id)}')"
        @sqllite.execute(query)
      rescue Exception => e
        #puts e
        return false
      end
    end
    protein
  end

  def add_ppi(protein_1, protein_2, conf_type, conf_value)
    begin
      # Inserta en base de datos
      query = "INSERT INTO #{@interactionsTable} VALUES ('#{clean_value(protein_1.protein_id)}','#{clean_value(protein_2.protein_id)}','#{clean_value(conf_type)}','#{conf_value}')"
      @sqllite.execute(query)
    rescue SQLite3::Exception => e
    end
  end

  def get_kegg(gene_id)
    get_kegg_from_gene(gene_id)
  end

  def add_kegg(gene, kegg_id, kegg_description)
    begin
      kegg = get_kegg_from_gene_and_kegg(gene.gene_id, kegg_id)
      if !kegg
        # Inserta en base de datos
        query = "INSERT INTO #{@keggTable} (gene_id, kegg_id, kegg_description) VALUES ('#{gene.gene_id}','#{clean_value(kegg_id)}','#{clean_value(kegg_description)}')"
        @sqllite.execute(query)
      end
    rescue SQLite3::Exception => e
      # puts e
    end
  end

  def get_go(gene_id)
    get_go_from_gene(gene_id)
  end

  def add_go(gene, go_id, go_description)
    begin
      go = get_go_from_gene_and_go(gene.gene_id, go_id)
      if !go
        # Inserta en base de datos
        query = "INSERT INTO #{@goTable} (gene_id, go_id, go_description) VALUES (\"#{gene.gene_id}\",\"#{clean_value(go_id)}\",\"#{clean_value(go_description)}\")"
        @sqllite.execute(query)
      end
    rescue SQLite3::Exception => e
      puts e
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
    if gene
      query = "SELECT * FROM #{@geneLinkedTable} WHERE gene_id_1 = '#{gene_id}'"
      linked_gene = @sqllite.execute(query)

      # Iterate linked genes, get gene_2
      linked_gene.each do |gene_linked_data|
        gene_linked = get_single_gen(gene_linked_data[1])
        gene.add_linked_gene(gene_linked)
      end
      protein = get_single_protein_by_gen(gene)
      gene.protein = protein
      kegg_db = get_kegg_from_gene(gene)
      kegg_list = []
      kegg_db.each do |kegg|
        kegg_list.push({
                           "id": kegg[2],
                           "description": kegg[3]
                       })
      end
      gene.kegg_list = kegg_list

      go_db = get_go_from_gene(gene)

      go_list = []
      go_db.each do |go|
        go_list.push({
                         "id": go[1],
                         "description": go[2]
                     })
      end
      gene.go_list = go_list
    end
    gene
  end

  def get_protein(protein_id)
    get_single_protein(protein_id)
  end

  def get_protein_by_gene(gene)
    get_single_protein_by_gen(gene)
  end

  def get_ppi(protein_id)
    query = "SELECT * FROM #{@interactionsTable} WHERE protein_id_1 = '#{protein_id}'"
    protein_list = []
    db_protein_list = @sqllite.execute(query)
    if db_protein_list.length > 0
      db_protein_list.each do |ppi|
        protein_list.push(get_single_protein(ppi[1]))
      end
    end
    protein_list
  end

  def link_gene(gene_id_1, gene_id_2)
    query = "INSERT INTO #{@geneTable} VALUES ('#{gene_id_1}','#{gene_id_2}')"
    @sqllite.execute(query)
  end

  def print()
    puts "\t------------Genes Table------------"
    @genes_list.each { |gene| gene.print() }
  end


  private

  def get_single_gen(gene_id)
    query = "SELECT * FROM #{@geneTable} WHERE id = '#{gene_id}'"

    db_gene_list = @sqllite.execute(query)
    if db_gene_list.length > 0
      db_gene = db_gene_list[0]
      Gene.new(db_gene[0], db_gene[1], db_gene[2])
    else
      false
    end
  end

  def get_single_protein(protein_id)
    query = "SELECT * FROM #{@proteinTable} WHERE protein_id = '#{protein_id}'"

    db_protein_list = @sqllite.execute(query)
    if db_protein_list.length > 0
      db_protein = db_protein_list[0]
      protein_id = db_protein[0]
      gene_id = db_protein[1]
      gene = get_single_gen(gene_id)
      return Protein.new(protein_id, gene)
    else
      false
    end

  end

  def get_single_protein_by_gen(gene)
    query = "SELECT * FROM #{@proteinTable} WHERE gene_id = '#{gene.gene_id}'"

    db_protein_list = @sqllite.execute(query)
    db_protein = db_protein_list[0]
    protein_id = db_protein[0]
    Protein.new(protein_id, gene)
  end

  def get_kegg_from_gene(gene_id)
    query = "SELECT * FROM #{@keggTable} WHERE gene_id = '#{gene_id}'"
    kegg_list = @sqllite.execute(query)
    kegg_list[0]
  end

  def get_kegg_from_gene_and_kegg(gene_id, kegg_id)
    query = "SELECT * FROM #{@keggTable} WHERE gene_id = '#{gene_id}' AND kegg_id = '#{kegg_id}'"
    kegg_db = @sqllite.execute(query)
    if kegg_db.length > 0
      kegg_db[0]
    else
      false
    end
  end

  def get_go_from_gene(gene_id)
    query = "SELECT * FROM #{@goTable} WHERE gene_id = '#{gene_id}'"
    kegg_list = @sqllite.execute(query)
    kegg_list[0]
  end

  def get_go_from_gene_and_go(gene_id, go_id)
    query = "SELECT * FROM #{@goTable} WHERE gene_id = '#{gene_id}' AND go_id = '#{go_id}'"
    @sqllite.execute(query)
    go_db = @sqllite.execute(query)
    if go_db.length > 0
      go_db[0]
    else
      false
    end
  end

  def delete_table(table)
    query = "DELETE FROM #{table}"
    @sqllite.execute(query)
  end

  def clean_value(text)
    text.gsub('"', %q(\\\"))
  end
end