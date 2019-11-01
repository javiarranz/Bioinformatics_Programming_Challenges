require 'rest-client'
require './assignment_2/lib/EbiDbfetchApi'
require './assignment_2/lib/TogoRestApi'
require './assignment_2/lib/file_parser'
require './assignment_2/dao/GeneDatabase'
require './assignment_2/models/Gene'


class Assignment2
  attr_reader :ebi_api
  attr_reader :togo_api
  attr_reader :arabidopsis_genelist

  attr_reader :gene_database

  def initialize(arguments)
    puts "Start First Assignment"
    @ebi_api = EbiDbfetchApi.new
    @togo_api = TogoRestApi.new
    @gene_database = GeneDatabase.new


    path_fixtures = './assignment_2/fixtures'
    @arabidopsis_genelist = FileParser.new(path_fixtures, 'test_ArabidopsisSubNetwork_GeneList.tsv')
    gene_rows = @arabidopsis_genelist.rows

    gene_rows.each { |row| @gene_database.add_gene(Gene.new(row['Gene_ID'], "", "")) }
    # @gene_database.print
  end



  def exercise_1()
    puts %(\n\n** Exercise 1 **

-------------------------------------------------------------------------------------------------------------------------------------\n\n)
    genes_list = @gene_database.genes_list
    puts genes_list

    # genes_list.each do |gene|
    #   ebifetch = @ebi_api.get("ensemblgenomesgene", "embl", gene.gene_id, "raw")
    #   gene.ebi_dbfetch = ebifetch



      #togofetch = @togo_api("kegg-genes", gene.gene_id)
      #gene.togo_dbfetch = togofetch
    #end

    n_gene = @gene_database.get_gene("AT5G54270")
    puts n_gene
  end


  def exercise_2()

    puts %(\n\n** Exercise 2 **

-------------------------------------------------------------------------------------------------------------------------------------\n\n)

  end

  def bonus_1()
    puts %(\n\n** Bonus 1 **

-------------------------------------------------------------------------------------------------------------------------------------\n\n)
    puts "\t----- SOLUTION -----"

  end

  def bonus_2()
    puts "\n\n** Bonus 2 **

-------------------------------------------------------------------------------------------------------------------------------------\n\n"
    puts "\t----- SOLUTION -----"

  end
end

