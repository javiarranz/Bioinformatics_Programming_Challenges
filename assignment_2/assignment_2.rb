require './lib/Generate_Database'
require './models/Interaction_Network'
require './dao/GeneDatabase'


puts "\n\n\n\n"
puts "************************"
puts "**      PLEASE        **"
puts "**   Read comments    **"
puts "************************"

puts "\n\n\n\n"
puts "*********************************"
puts "**                             **"
puts "**      DATABASE ALREADY       **"
puts "**            CREATED          **"
puts "**                             **"
puts "**  KEEP THE VALUE AS FALSE    **"
puts "**                             **"
puts "*********************************"
puts "\n\n\n\n"


#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#----------------------PLEASE READ THIS COMMENTS BEFORE RUN-------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#

# Here we create a database using SqLite in where we're gonna save all our data
#       IMPORTANT!!!!!
# THE DATABASE IS ALREADY CREATED AND STORED IN SQLite, CALLED biology.db
# In case you want to clean the database and redoing it, just uncomment the GenerateDatabase.New
# with the (TRUE) Statement between brackets. It takes too much time to created again.
# That is why I included the database in the github.
#
#
#
# I do this database because I called the database too many times (too much time)
#
# Other reason is that when I started trying to get the data, the web crashed several times
# and I was not able to obtain the data, so when I could, I stored it to call it.
#
# This is also helpful in a company when you pay each time you call a data in a database




#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#---------------------------GENERATE DATABASE---------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#

puts "ASSIGNMENT 2"

@gene_database = GeneDatabase.new()
# generateDatabase = Generate_database.new(true)         # ==> TRUE TO CLEAN and REDO THE DATABASE
generateDatabase = Generate_database.new(false)    # ==> FALSE TO NOT CLEAN THE DATABASE (DEFAULT)


      # Using only the Gene Ids from the Arabidopsis.tsv file
#gene_rows_list = generateDatabase.get_original_gene_ids
      # If we want to create a network with all nodes in DB uncomment this
 gene_rows_list = generateDatabase.get_all_genes




#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-------------------------RECURSIVE FUNCTION----------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#

# Here I create a recursive function. THIS IS HOW IT WORKS
#
# The function creates a node (adding a gene)
#
# The function has a parameter level, which is going to be decreasing each loop
# until it reaches level = 1 where it returns the network
#
# if the parameter level is still higher than 1, the function gets all the ppis
# from the database and store it in a variable.
# For each ppi, we get its ppi using the gene, that contains all the information such as KEGG or GO
# With this gene, I call again the recursive function in orther tu start again, but in this case
# the level will be -1.
#
# This way it iterates all the levels that we want changing only one parameter. Level

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


#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#
#------------------------------SAVING THE FILE--------------------------------------------#
#-----------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------#

# To create a new output file, I just use a File.open("new_file,"w") to create it
# then i use file.puts to write in the database and I created a personal format where
# all the data is shown in the output file
# HERE I ALSO CALL THE RECURSIVE FUNCTION WHILE CREATING THE FILE

name_file = "Networks_original"
name_file = "Networks_all_database"
File.open("outputs/" + name_file +".txt", "w") do |file|
  interaction_network_list = []
  gene_rows_list.each_with_index do |gene, index|
    # Added first Gene Node
    interaction_network = recursive_network(InteractionNetwork.new(index + 1), gene, 4)
                      # As I found many networks with 1-2 nodes, I have set a
                      # MINIMAL NUMBER OF NODES TO INCLUDE AS A NETWORK
                      # If you want all, just change the value (currently = 5)
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