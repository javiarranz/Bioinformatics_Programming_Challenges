require './assignment_2/lib/Generate_Database'
require './assignment_2/models/Interaction_Network'
require './assignment_2/dao/GeneDatabase'


puts "\n\n\n\n"
puts "************************"
puts "**      PLEASE        **"
puts "**   Read comments    **"
puts "************************"

puts "\n\n\n\n"
puts "*********************************"
puts "**                             **"
puts "**      RUN ONLY ONE TIME      **"
puts "**  TO CREATE THE DATABASE     **"
puts "**                             **"
puts "**  THEN CHANGE VALUE TO FALSE **"
puts "**                             **"
puts "*********************************"
puts "\n\n\n\n"

# Here we create a database using SqLite in where we're gonna save all our data
#
# I do this because I call the database too many times
# Other reason is that when I started trying to get the data, the web crashed several times
# and I was not able to obtain the data, so when I could, I stored it to call it.
#
# This is also helpful in a company when you pay each time you call a data in a database


#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#


# START WITH TRUE THE FIRST TIME TO CREATE DATABASE, THEN CHANGE IT TO FALSE AND USE THE DATABASE


generateDatabase = Generate_database.new(true)         # ==> TRUE TO CLEAN THE DATABASE
#generateDatabase = Generate_database.new(false)   # ==> FALSE TO NOT CLEAN THE DATABASE
generateDatabase.create_database()


# def create_network(levels = 3, gene)
#   gene_rows_list.each do |gene|
#
#     @interaction_network = InteractionNetwork.new()
#     nodes_list = network.add_node(gene.gsub("\n", ""))
#
# # Level 1
#     first_level_genes = @interaction_network.get_gene_interactions(gene)
#     first_level_genes.each do |gene_l2|
#       @interaction_network.add_node(gene_l2, gene)
#       puts "nodes list contains #{nodes_list.length} genes"
#       # Level 2
#       @interaction_network.get_gene_interactions(gene_l2).each do |gene_l3|
#         network.add_node(gene_l3, gene_l2)
#         puts "nodes list contains #{nodes_list.length} genes"
#         # Level 3
#         @interaction_network.get_gene_interactions(gene_l3).each do |gene_l4|
#           network.add_node(gene_l4, gene_l3)
#           puts "nodes list contains #{nodes_list.length} genes"
#         end
#       end
#     end
#   end
# end


#end

# decidir como se monta la network
# select (te traes todos los genes)
# vas uno a uno, gen a gen
# crear todas las redes de 1 nivel posibles
# funcion recursiva (que se llama a si misma)
#
#
#
# creamos una lista
# tengo una funcion que me trae todos los genes
# la llamas (lista con todos)
# los iteras
# para cada uno de esos, haces otra funcion que coja el ID y llamme a base de datos (slect) que te traiga el propio gen
# y que te traiga sus interacciones
# para cada interaccion llamas a base de datos para que te traiga ese gen, y sus interacciones
#
#
#
# -----------------------------------------------------------------------------------------------------------------
#
# # path_fixtures = './assignment_2/fixtures'
# # arabidopsis_genelist = FileParser.new(path_fixtures, 'ArabidopsisSubNetwork_GeneList.tsv')
# # gene_rows = arabidopsis_genelist.rows
# #
# # # I create a list containing all locus gene
# # gene_rows_list = []
# # gene_rows.each do |row|
# #   gene_id = row["Gene_ID"]
# #   gene_rows_list.append(gene_id)
# # end