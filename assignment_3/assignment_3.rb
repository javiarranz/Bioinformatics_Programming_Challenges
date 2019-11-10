require 'rest-client'
# require 'bio'
require './lib/rest/EbiDbfetchRestApi'
require './lib/file_parser'

@file_name = 'ArabidopsisSubNetwork_GeneList.tsv'
@ebi_api = EbiDbfetchRestApi.new

def parse_original_file
  path_fixtures = './fixtures'
  @arabidopsis_genelist = FileParser.new(path_fixtures, @file_name)
end

parse_original_file
gene_rows = @arabidopsis_genelist.rows
#puts gene_rows

gene_rows.each do |row|
  puts row['Gene_ID'].upcase
end

# EBI API ==> TO GET TEH SEQUENCES
# ----------------------------------
# gene_rows.each do |row|
#   ebifetch = @ebi_api.get("ensemblgenomesgene", "fasta", gene.gene_id, "raw")
#   if ebifetch
#     puts "Encontrado para #{gene.gene_id}"
#   # else
#   #   puts "No Encontrado para #{gene.gene_id}"
#   end
# end


puts "ASSIGNMENT 3"

#@gene_database = GeneDatabase.new()
# generateDatabase = Generate_database.new(true)         # ==> TRUE TO CLEAN and REDO THE DATABASE
#generateDatabase = Generate_database.new(false)    # ==> FALSE TO NOT CLEAN THE DATABASE (DEFAULT)

# name_file = "20_NA_sequence"
# File.open("outputs/" + name_file +".txt", "w") do |file|
#   file.puts "ATATTCTTCTTACTGATCACTGACTAGCTACTTACTGCATTAAGAAGTCATCG"
#   file.puts "TATAAGAAGAATGACTAGTGACTGATCGATGAATGACGTAATTCTTCAGTAGC"
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
