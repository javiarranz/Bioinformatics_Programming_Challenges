require 'rest-client'
require 'bio'
require './assignment_3/lib/rest/EbiDbfetchRestApi'
require './assignment_3/lib/file_parser'

#@file_name = 'ArabidopsisSubNetwork_GeneList.tsv'
@file_name = 'ArabidopsisSubNetwork_GeneList_test.tsv'
@ebi_api = EbiDbfetchRestApi.new
@target = "cttctt"
@target_length = @target.length


puts "ASSIGNMENT 3"
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#
# FIST, I CREATE AN OUTPUT WITH A SHORT SEQUENCE TAT CONTAINS CTTCTT IN 5'->3' IN BOTH STRANDS
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#

seq = Bio::Sequence::NA.new("ATATTCTTCTTACTGATTAAGAAGTCATCG")
puts seq

name_file = "20_NA_sequence"
File.open("assignment_3/outputs/" + name_file +".txt", "w") do |file|
  file.puts seq
  file.puts seq.complement
end


# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#
# NOW I READ ALL THE GENES FROM THE LIST TO THEN ITERATE THEM TO GET THE SEQUENCES
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#

def parse_original_file
  path_fixtures = './assignment_3/fixtures'
  @arabidopsis_genelist = FileParser.new(path_fixtures, @file_name)
end

parse_original_file
gene_rows = @arabidopsis_genelist.rows
#puts gene_rows

def new_file(filename)
  if File.exists?(filename)
    File.delete(filename) # We remove the file in case it exits to update it
  end
  File.open(filename)
end

# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#
# I USE EBI API ==> TO GET TEH SEQUENCES
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#

gene_rows.each do |row|
  gene = row['Gene_ID'].upcase
  gene_cleaned = gene.gsub("\n","")
  fasta = @ebi_api.get("ensemblgenomesgene", "fasta", gene_cleaned, "raw")
  #@ebi_api.get("ensemblgenomesgene", "fasta", gene_cleaned, "raw")
  entry = Bio::EMBL.new(fasta)
  entry.to_biosequence
  bioseq = entry.to_biosequence
  bioseq

  #seq = Bio::Sequence::NA.new(fasta)
end









#@gene_database = GeneDatabase.new()
# generateDatabase = Generate_database.new(true)         # ==> TRUE TO CLEAN and REDO THE DATABASE
#generateDatabase = Generate_database.new(false)    # ==> FALSE TO NOT CLEAN THE DATABASE (DEFAULT)

#
#
# end
# puts "Finish"
#
#
#
# end




#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
##
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------#
#FORMA DE HACERLO DEL PROFESOR
#
# require 'net/http'
#
# def fetch(uri_str)  # this "fetch" routine does some basic error-handling.
#
#   address = URI(uri_str)  # create a "URI" object (Uniform Resource Identifier: https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
#   response = Net::HTTP.get_response(address)  # use the Net::HTTP object "get_response" method
#   # to call that address
#
#   case response   # the "case" block allows you to test various conditions... it is like an "if", but cleaner!
#   when Net::HTTPSuccess then  # when response is of type Net::HTTPSuccess
#     # successful retrieval of web page
#     return response  # return that response object
#   else
#     raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
#     # note - if you want to learn more about Exceptions, and error-handling
#     # read this page:  http://rubylearning.com/satishtalim/ruby_exceptions.html
#     # you can capture the Exception and do something useful with it!
#     response = false
#     return response  # now we are returning False
#   end
# end
#
#
# genes = File.open('./files/short_gene_list.txt', 'r')
# fastaoutput = File.open('./files/ARA.fa', 'w')
#
# genearray = genes.read.split()
# geneids=genearray.join(",")
#
# url = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=#{geneids}"
#
# puts url
# res = fetch(url)
# puts res.body
# fastaoutput.write(res.body)
#
# genes.close
# fastaoutput.close
#
#
# puts "done - now check your fasta output in /UPM_BioinfoCourse/Lectures/files/ARA.fa"
