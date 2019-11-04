class InteractionNetwork

  attr_accessor :network_id # The number that identifies the network
  attr_accessor :num_nodes # Number of nodes that the networks has
  attr_accessor :members # Array containing the Gene objects from the given file that belong to the network

  def initialize (network_id = "X", num_nodes = 0, members = Hash.new )

    @network_id = network_id
    @num_nodes = num_nodes
    @members = members
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
end