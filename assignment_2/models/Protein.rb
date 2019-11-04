
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
    else
      raise("...")
      #raise("The protein ID should have the right format (/[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}/)")
    end
  end


  private
    #
    # def get_prot_intactcode(gene_id)
    #   # Class method that searchs whether a given protein is present in IntAct database or not
    #   # If it is, the function will return th IntAct ID
    #
    #   address = URI("http://togows.org/entry/ebi-uniprot/#{gene_id}/dr.json")
    #   response = Net::HTTP.get_response(address)
    #
    #   data = JSON.parse(response.body)
    #
    #   if data[0]['IntAct']
    #     return data[0]['IntAct'][0][0] # If the protein is present, the result returned will be the protein accession code. If it not, the result will be empty
    #   else
    #     return nil
    #   end
    #
    #
    # end

end