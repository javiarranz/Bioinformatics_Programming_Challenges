require './assignment_2/dao/GeneDatabase'
require './assignment_2/models/Gene'
require './assignment_2/models/Protein'

class InteractionNetwork

  attr_accessor :network_id # The number that identifies the network
  attr_accessor :node_list # Array containing the nodes of the network

  def initialize (network_id)
    @network_id = network_id
    @node_list = []
  end

  def get_gene_interactions(gene)
    gene.get_ppi
  end

  def add_node(gene)
    @node_list.push(gene)
  end

end