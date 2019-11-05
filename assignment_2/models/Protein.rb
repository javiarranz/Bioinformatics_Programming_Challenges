
class Protein

  attr_accessor :protein_id
  attr_accessor :gene
  # attr_accessor :intact_id
  # attr_accessor :network


  def initialize(protein_id, gene)
    @linked_genes = []
    protein_id = protein_id.upcase
    protein_id = protein_id.gsub("\n", '')
    @gene = gene

    if protein_id =~ /[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}/
      @protein_id = protein_id
    # else
    #   raise("...")
      #raise("The protein ID should have the right format (/[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}/)")
    end
  end

end

# CLASS PROTEIN TO STORE THE INFORMATION OF EACH PROTEIN