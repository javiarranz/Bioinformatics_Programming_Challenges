require 'rest-client'
require './assignment_4/lib/file_parser'
require './assignment_4/models/Gene'
require 'bio'
require 'stringio'
require 'io/console'


@file_name = 'pep_javier.fa'



def parse_file
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # FUNCTION TO PARSE A FILE
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  path_fixtures = './assignment_4/fixtures'
  @pep = FileParser.new(path_fixtures, @file_name)
end

def new_file(name_file, items_list, format)
  File.open("./outputs/" + name_file + format, "w") do |file|
    file.puts "##gff-version 3"
    items_list.each do |chromosome|
      file.puts chromosome
    end
  end
end

def init_assingment()
  puts "ASSIGNMENT 4"

  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # FIRST, I CREATE A DATABASE AND SOME INDEX THAT ARE USED BY BLASE TO SPEED-UP THE SEARCH
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#


  parse_file
  puts @pep

  system("makeblastdb -in '#{@pep}' -dbtype 'nucl' -out ./assignment_4/dao/pep_javier_index")
  # system("makeblastdb -in '#{target_file}' -dbtype #{type_target_file} -out ./Databases/#{db_target.to_s}")

  factory = Bio::Blast.local('blastn', './assignment_4/dao/pep_javier_index')



  # parse_original_file
  # gene_rows = @arabidopsis_genelist.rows

  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # I USE EBI API ==> TO GET TEH SEQUENCES
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#


  puts "\n\n\n\n"
  puts "##################################"
  puts "####                          ####"
  puts "####     XXXXXXXXXXXXXXXXX    ####"
  puts "####                          ####"
  puts "##################################"
  puts "\n\n"
  #Lets create an output with the GENES that didn't have the target sequence as a record

  puts "RESULTS: ________________________________________"
  puts ""
  puts ""
  puts ""
  puts ""



end



# ------------------------------------------------#
# HERE WE CALL THE FUNCTION TO INIT THE ASSIGNMENT
# ------------------------------------------------#


init_assingment

puts "Finished."

#____________________________________________________________________________________________________________________#
#




