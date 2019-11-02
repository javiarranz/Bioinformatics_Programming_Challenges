#
# require 'rest-client'
# require './assignment_2/lib/EbiDbfetchApi'
# require './assignment_2/lib/TogoRestApi'
# require './assignment_2/lib/file_parser'
# require './assignment_2/dao/GeneDatabase'
# require './assignment_2/models/Gene'
# require './assignment_2/lib/Assignment_2'
#
#
# puts "Start First Assignment"
# ebi_api = EbiDbfetchRestApi.new
# togo_api = TogoRestApi.new
# psicquic_api = PsicquicRestApi.new
# gene_database = GeneDatabase.new
# arabidopsis_genelist = FileParser.new(path_fixtures, 'test_ArabidopsisSubNetwork_GeneList.tsv')
#
# def initialize(arabidopsis_genelist, gene_database)
#   puts "Start First Assignment"
#
#   path_fixtures = './assignment_2/fixtures'
#
#   gene_rows = arabidopsis_genelist.rows
#
#   gene_rows.each {|row| gene_database.add_gene(Gene.new(row['Gene_ID'], "", ""))}
# end
#
# def exercise_1(gene_database, ebi_api)
#   puts %(\n\n** Exercise 1 **
#
# -------------------------------------------------------------------------------------------------------------------------------------\n\n)
#   genes_list = gene_database.genes_list
#   puts genes_list
#
#   genes_list.each do |gene|
#     ebifetch = ebi_api.get("ensemblgenomesgene", "embl", gene.gene_id, "raw")
#     gene.ebi_dbfetch = ebifetch
#   end
#
#   #togofetch = @togo_api("kegg-genes", gene.gene_id)
#   #gene.togo_dbfetch = togofetch
#   #end
#
#   n_gene = gene_database.get_gene("AT5G54270")
#   puts n_gene
# end
#
# initialize(arabidopsis_genelist, gene_database)
# exercise_1(gene_database, ebi_api)
#
