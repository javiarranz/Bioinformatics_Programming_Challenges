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
# generateDatabase = Generate_database.new(true)         # ==> TRUE TO CLEAN THE DATABASE
generateDatabase = Generate_database.new(false) # ==> FALSE TO NOT CLEAN THE DATABASE

# Using only the Gene Ids from the Arabido.... tsv file
gene_rows_list = generateDatabase.get_original_gene_ids
# gene_rows_list = generateDatabase.get_all_genes # If we want to create a network with all nodes in DB


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

File.open("assignment_2/output_all_networks.txt", "w") do |file|
  interaction_network_list = []
  gene_rows_list.each_with_index do |gene, index|
    # Added first Gene Node
    interaction_network = recursive_network(InteractionNetwork.new(index + 1), gene, 5)
    if interaction_network.node_list.length > 5
      interaction_network_list.push(interaction_network)
      puts "Network #{interaction_network.network_id} with #{interaction_network.node_list.length} nodes"
      file.puts "Network #{interaction_network.network_id} with #{interaction_network.node_list.length} nodes"
      interaction_network.node_list.each do |gene|
        file.puts "    Gen #{gene.gene_id}"
        file.puts "       - Keggs:"
        if gene.kegg_list.length > 0

          gene.kegg_list.each do |kegg|
            file.puts "              - #{kegg[:id]} => #{kegg[:description]}"
          end
        else
          file.puts "              - Not found"
        end
        file.puts "       - Go:"
        if gene.go_list.length > 1
          gene.go_list.each do |go|
            file.puts "             - #{go[:id]} with Term Name: #{go[:description]}"
          end
        else
          file.puts "              - Not found"
        end
      end

    end
  end
end

puts "Finish"