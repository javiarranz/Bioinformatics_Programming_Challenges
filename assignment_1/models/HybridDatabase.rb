class HybridDatabase

  attr_accessor :hybrid_list

  def initialize()

    puts "Initiliazing Hybrid Database"
    @hybrid_list = []
  end

  def add_hybrid(hybrid)
    @hybrid_list.append(hybrid)
  end

  def print()
    puts "\n\n------------Hybrid Cross Table------------"
    @hybrid_list.each { |hybrid| hybrid.print() }
  end
end