require './assignment_2/lib/Assignment_2'


# assignment_2 = Assignment2.new(true)
# assignment_2 = Assignment2.new(false)
#
# assignment_2.create_database()


# EJemplo recursividad
def recur_fact(num)
  if num == 0 || num == 1
    1
  else
    num * recur_fact(num - 1)
  end
end

puts recur_fact(3)


def create_network(levels = 3, gene)

  n = Network.new()

  n.add_node(gene)
  # Nivel 1
  get_gene_interactions(gene).each do |gene_l2|
    n.add_node(gene_l2, gene)
    # Nivel 2
    get_gene_interactions(gene_l2).each do |gene_l3|
      n.add_node(gene_l3, gene_l2)

      get_gene_interactions(gene_l3).each do |gene_l4|
        n.add_node(gene_l4, gene_l3)
      end
    end
  end
end

end