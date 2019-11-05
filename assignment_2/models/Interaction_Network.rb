require './assignment_2/dao/GeneDatabase'
require './assignment_2/models/Gene'
require './assignment_2/models/Protein'

class InteractionNetwork

  attr_accessor :network_id # The number that identifies the network
  attr_accessor :num_nodes # Number of nodes that the networks has
  attr_accessor :members # Array containing the Gene objects from the given file that belong to the network

  def initialize (network_id = "X", num_nodes = 0, members = Hash.new )

    @network_id = network_id
    @num_nodes = num_nodes
    @members = members
  end

  def get_gene_interactions(gene)
    gene.get_ppi
  end

  def add_node(gene)
    node_list = []
    node_list.append(gene)
  end

  #TODO this functions
  #
  # def add_network
  #
  # end
  #
  # def remove_network
  #
  # end
  #
  #
  # def assign
  #
  # end
  #
#

end