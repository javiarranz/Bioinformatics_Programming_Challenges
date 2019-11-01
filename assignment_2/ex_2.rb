
require 'rest-client'
require './assignment_2/lib/EbiDbfetchApi'
require './assignment_2/lib/TogoRestApi'
require './assignment_2/lib/file_parser'
require './assignment_2/dao/GeneDatabase'
require './assignment_2/models/Gene'
require './assignment_2/lib/Assignment_2'

# puts "Start First Assignment"
# ebi_api = EbiDbfetchApi.new
# togo_api = TogoRestApi.new
# gene_database = GeneDatabase.new
#
# path_fixtures = './assignment_2/fixtures'
# @arabidopsis_genelist = FileParser.new(path_fixtures, 'test_ArabidopsisSubNetwork_GeneList.tsv')
# gene_rows = @arabidopsis_genelist.rows
#
# gene_rows.each { |row| gene_database.add_gene(Gene.new(row['Gene_ID'], "", "")) }
# gene_database.print


#
# puts %(\n\n** Exercise 1 **
# -------------------------------------------------------------------------------------------------------------------------------------\n\n)
# genes_list = gene_database.genes_list
# genes_list_id = []
# genes_list.each { |gene| genes_list_id.append(gene.print)}
#
# puts genes_list_id

# genes_list_id.each do |gene|
# ebifetch = @ebi_api.get("ensemblgenomesgene", "embl", gene.gene_id, "raw")
# gene.ebi_dbfetch = ebifetch
# end


#togofetch = @togo_api("kegg-genes", gene.gene_id)
#gene.togo_dbfetch = togofetch









#TODO (THIS PART IS COPIED FROM THE SLIDES TO CHECK IF THIS WORKS, REMOVE)
address = 'http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=uniprotkb&format=uniprotkb&id=P17839'

response = RestClient::Request.execute(
    method: :get,
    url: address)  # use the Net::HTTP Class "get_response" method
#to call that address
puts response.body


#------------------------------------------------------------------------------------------#

#TODO (MOVE THIS CODE TO THE RIGHT PART, COPIED FROM THE SLIDES)

# def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
#   response = RestClient::Request.execute({
#                                              method: :get,
#                                              url: url.to_s,
#                                              user: user,
#                                              password: pass,
#                                              headers: headers})
#   return response
#
# rescue RestClient::ExceptionWithResponse => e
#   $stderr.puts e.response
#   response = false
#   return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
# rescue RestClient::Exception => e
#   $stderr.puts e.response
#   response = false
#   return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
# rescue Exception => e
#   $stderr.puts e
#   response = false
#   return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
# end
#
#
# res = fetch('http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=At3g54340');
# #puts res.class
# #puts res.public_methods
#
# if res  # res is either the response object, or False, so you can test it with 'if'
#   #body = res.body  # get the "body" of the response
#   body = res.body
#   if body =~ /locus_tag="([^"]+)"/  #get anything that is not a quote
#     gene_name = $1
#     puts "the name of the gene is #{gene_name}"
#
#     ## THIS IS THE CORRECT WAY TO DO IT
#     #puts body
#     #gene_name_regexp = Regexp.new(/locus_tag="([^"]+)"/)  # this is one way to do Regular Expressions in Ruby.  There are several!
#     #match = gene_name_regexp.match(body)
#     #if match
#     #  gene_name = match[1]  # matches act like an array, so the first match is [1]
#     # (try for yourself, what is match[0]?)
#     #  puts "the name of the gene is #{gene_name}"
#   else
#     begin  # use a "begin" block to handle errors
#       puts "There was no record"  # print a friendly message
#       raise "this is an error" # raise an exception
#     rescue # some code to rescue the situation... for example, maybe a different regexp?
#       puts "exiting gracefully"  # in this case, we are just going to stop trying
#     end
#   end
# end
























#assignment_2 = Assignment2.new(ARGV)



#puts "\n\n----------------EXERCISES------------------"
#assignment_2.exercise_1
# # assignment_2.exercise_2
# # puts "\n\n----------------BONUS POINTS------------------"
# # assignment_2.bonus_1
# # assignment_2.bonus_2