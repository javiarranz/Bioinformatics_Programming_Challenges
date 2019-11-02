require './lib/TogoRestApi'
require 'rest-client'
require 'json'
# require './assignment_2/dao/GeneDatabase'
# require './assignment_2/models/Gene'

class Protein

  attr_accessor :protein_id
  attr_accessor :intact_id
  attr_accessor :network


  def initialize(protein_id, protein_name, intact_id, network = nil)
    @linked_genes = []
    protein_id = protein_id.upcase
    protein_id = protein_id.gsub("\n", '')
    protein_name = protein_name.gsub("\n", '')
    intact_id = intact_id.upcase
    intact_id = intact_id.gsub("\n", '')

    if protein_id =~ /[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}/
      @protein_id = protein_id
    else
      abort("The protein ID should have the right format (ATxGxxxxx), where x is a number")
    end
    if gene_name != ""
      @protein_name = protein_name
    else
      @protein_name = nil
    end
    @network = network
  end


  def print()
    message = "\tGene "

    if @protein_name != nil
      message += "#{@gene_name} (#{@gene_id})"
    else
      message += "#{@gene_name}"
    end

    if @mutant_phenotype != ""
      message += "==> #{@mutant_phenotype}"
    end

    if @linked_genes.length > 0
      linked = ''
      @linked_genes.each {|gene| linked += "#{gene.gene_name} (#{gene.gene_id}), "}
      linked = linked.delete_suffix!(', ')
      message += " and is linked to #{linked}"
    end
    puts message
  end



  private

  def get_prot_intactcode(gene_id)
    # Class method that searchs whether a given protein is present in IntAct database or not
    # If it is, the function will return th IntAct ID

    address = URI("http://togows.org/entry/ebi-uniprot/#{gene_id}/dr.json")
    response = Net::HTTP.get_response(address)

    data = JSON.parse(response.body)

    if data[0]['IntAct']
      return data[0]['IntAct'][0][0] # If the protein is present, the result returned will be the protein accession code. If it not, the result will be empty
    else
      return nil
    end


  end

end