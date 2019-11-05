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


# WHEN RUNNING THE EXERCISE FOR THE FIRST TIME
# START WITH TRUE THE FIRST TIME TO CREATE THE DATABASE
# THEN CHANGE IT TO FALSE AND USE THE DATABASE


#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#

puts "ASSIGNMENT 2"
@gene_database = GeneDatabase.new()
#generateDatabase = Generate_database.new(true)         # ==> TRUE TO CLEAN THE DATABASE
generateDatabase = Generate_database.new(false) # ==> FALSE TO NOT CLEAN THE DATABASE
#generateDatabase.create_database()

# DESDE AQUI
#def create_network(levels = 3, gene)
# path_fixtures = './assignment_2/fixtures'
# arabidopsis_genelist = FileParser.new(path_fixtures, 'ArabidopsisSubNetwork_GeneList.tsv')
# gene_rows = arabidopsis_genelist.rows
# gene_rows_list = []
# gene_rows.each do |row|
#   gene_id = row["Gene_ID"]
#   gene_rows_list.append(gene_id)
# end
generateDatabase.get_original_gene_ids
gene_rows_list = generateDatabase.original_genes


def recursive_network(interaction_network, gene, level)
  interaction_network.add_node(gene)
  if level == 1
    return interaction_network
  elsif gene.protein
    ppi_level_1 = @gene_database.get_ppi(gene.protein.protein_id)
    ppi_level_1.each do |proteins|
      gene_id = proteins.gene.gene_id
      gene_ppi = @gene_database.get_gene(gene_id)
      if gene_ppi
        interaction_network = recursive_network(interaction_network, gene_ppi, level - 1)
      end
    end
  end
  interaction_network
end

File.open("output.txt", "w") do |file|

  interaction_network_list = []
  gene_rows_list.each_with_index do |gene, index|
    # Added first Gene Node
    interaction_network = recursive_network(InteractionNetwork.new(index + 1), gene, 4)
    if interaction_network.node_list.length > 1
      interaction_network_list.push(interaction_network)
      file.puts "Network #{interaction_network.network_id} with #{interaction_network.node_list.length} nodes"
      interaction_network.node_list.each do |gene|
        file.puts "    Gen #{gene.gene_id}"
        file.puts "       - Keggs:"
        gene.kegg_list.each do |kegg|
          file.puts "              - #{kegg[:id]} => #{kegg[:description]}"
        end
        file.puts "       - Go:"
        gene.go_list.each do |go|
          file.puts "             - #{go[:id]} with Term Name: #{go[:description]}"
        end
      end
      #
      # # Level 1
      # ppi_level_1 = gene_database.get_ppi(gene.protein.protein_id)
      # ppi_level_1.each do |gene_l2|
      #   interaction_network.add_node(gene_l2, gene)
      #   puts "nodes list contains #{nodes_list.length} genes"
      #   # Level 2
      #   interaction_network.get_gene_interactions(gene_l2).each do |gene_l3|
      #     interaction_network.add_node(gene_l3, gene_l2)
      #     puts "nodes list contains #{nodes_list.length} genes"
      #     # Level 3
      #     interaction_network.get_gene_interactions(gene_l3).each do |gene_l4|
      #       interaction_network.add_node(gene_l4, gene_l3)
      #       puts "nodes list contains #{nodes_list.length} genes"
      #     end
      #   end
      # end
    end
  end
end
# HASTA AQUI
puts "finish"
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
#
#
#