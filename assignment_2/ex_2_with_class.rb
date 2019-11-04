require './assignment_2/lib/Generate_Database'

puts "Read comments"
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
assignment_2 = Generate_database.new(true)
#assignment_2 = Generate_database.new(false)

assignment_2.create_database()




# def create_network(levels = 3, gene)
#
#   n = Network.new()
#
#   n.add_node(gene)
#   # Nivel 1
#   get_gene_interactions(gene).each do |gene_l2|
#     n.add_node(gene_l2, gene)
#     # Nivel 2
#     get_gene_interactions(gene_l2).each do |gene_l3|
#       n.add_node(gene_l3, gene_l2)
#
#       get_gene_interactions(gene_l3).each do |gene_l4|
#         n.add_node(gene_l4, gene_l3)
#       end
#     end
#   end
# end
