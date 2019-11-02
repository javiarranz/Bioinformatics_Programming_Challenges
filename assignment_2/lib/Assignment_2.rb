require 'rest-client'
require './assignment_2/lib/rest/EbiDbfetchRestApi'
require './assignment_2/lib/rest/TogoRestApi'
require './assignment_2/lib/rest/PsicquicRestApi'
require './assignment_2/lib/file_parser'
require './assignment_2/dao/GeneDatabase'
require './assignment_2/models/Gene'


class Assignment2
  attr_reader :ebi_api
  attr_reader :togo_api
  attr_reader :psicquic_api
  attr_reader :arabidopsis_genelist

  attr_reader :gene_database

  def initialize()
    puts "Start First Assignment"
    @ebi_api = EbiDbfetchRestApi.new
    @togo_api = TogoRestApi.new
    @psicquic_api = PsicquicRestApi.new
    @gene_database = GeneDatabase.new

    # @gene_database.clean_tables()

    path_fixtures = './assignment_2/fixtures'
    @arabidopsis_genelist = FileParser.new(path_fixtures, 'test_ArabidopsisSubNetwork_GeneList.tsv')
    # @arabidopsis_genelist = FileParser.new(path_fixtures, 'ArabidopsisSubNetwork_GeneList.tsv')
    gene_rows = @arabidopsis_genelist.rows

    gene_rows.each do |row|
      @gene_database.add_gene(row['Gene_ID'])
    end
    # @gene_database.print
  end


  def exercise_1()
    puts %(\n\n** Exercise 1 **

-------------------------------------------------------------------------------------------------------------------------------------\n\n)

    genes_list = @gene_database.get_all_genes_without_linked()
    #
    # # EBI API
    # genes_list.each do |gene|
    #   ebifetch = @ebi_api.get("ensemblgenomesgene", "embl", gene.gene_id, "raw")
    #
    #   if ebifetch
    #     puts "Encontrado para #{gene.gene_id}"
    #   else
    #     puts "No Encontrado para #{gene.gene_id}"
    #   end
    # end

    # Psicquiq
    genes_list.each do |gene|
      psicquic_fetch = @psicquic_api.get(gene.gene_id, 'xml25')
      if psicquic_fetch
        puts "Encontrado para #{gene.gene_id}"
      else
        puts "No Encontrado para #{gene.gene_id}"
      end
    end

    # Pasar el XML a JSON para trabajar mas facilmente
    # ir debugueando el json para sacar los datos necesarios.
    # Recorrer cada entry.
    # Recorrer cada interactorList para conocer los interactors
    #     Identificar el shortLabel (Q56YA5) basandonos en el locus name (At2g13360)
    #     poner siempre el que coincida con gene_id como primero.
    #     confidenceList tiene el nivel de confianza
    #     Cada interactor tiene sus Go
    # check organism - name -shortlabel = arath
    #
    # En interactionList, interaction, names, shortlabel sale un string con amnos interactors
    #
    #


    #togofetch = @togo_api("kegg-genes", gene.gene_id)
    #gene.togo_dbfetch = togofetch
    #end

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

