class InteractionNetwork

  attr_accessor :network_id # The number that identifies the network
  attr_accessor :num_nodes # Number of nodes that the networks has
  attr_accessor :members # Array containing the Gene objects from the given file that belong to the network

  def initialize (params = {})

    @network_id = params.fetch(:network_id, "X")
    @num_nodes = params.fetch(:num_nodes, "0")
    @members = params.fetch(:members, Hash.new)
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
  def
end