require 'rest-client'
# require './lib/file_parser'
# require './models/Gene'
require 'bio'
require 'stringio'
require 'io/console'


@pep_filename = 'pep_javier.fa'
@tair_filename = 'TAIR10_seq_20110103_representative_gene_model_updated'

def convert_to_hash(file)
  path = './assignment_4/fixtures/'

  bio = Bio::FastaFormat.open(path + file)

  hash = Hash.new
  bio.each do |seq_target|
    hash[(seq_target.entry_id).to_s] = (seq_target.seq).to_s
  end
hash
end

def make_blast(filename,dbtype, output)
  path = './dao/'
  system("makeblastdb -in '#{filename}' -dbtype #{dbtype} -out '#{path}#{output}'")
end

def new_file(name_file, items_list, format)
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # FUNCTION TO CREATE A NEW FILE
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

File.open("./assignment_4/outputs/" + name_file + format, "w") do |file|
    items_list.each do |row|
      file.puts row
    end
  end
end

def init_assingment()
  puts "ASSIGNMENT 4"
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # FIRST, I CREATE A HASH THAT CONTAINS EACH SEQUENCE (using a function I created above)
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  pep_hash = convert_to_hash('pep_javier.fa')
  tair_hash = convert_to_hash('TAIR10_seq_20110103_representative_gene_model_updated')

  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # THEN,  I CREATE THE DATABASES WITH BLAST (using a function I created for this)
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  dbtype_1 = 'prot'
  dbtpye_2 = 'nucl'

  puts '*** Making first file blast database...'
  #make_blast(@pep_filename,'prot', 'database_sp_1')
  puts '*** Making second file blast database...'
  #make_blast(@tair_filename,'nucl', 'database_sp_2')

  puts '  ** Bio::Blast.local => 1'
  puts '  ** Bio::Blast.local => 2'
  if dbtype_1 == 'nucl' and dbtpye_2 == 'nucl' # Both files contain genomes
    factory_sp1 = Bio::Blast.local('blastn', './dao/database_sp_1')
    factory_sp2 = Bio::Blast.local('blastn', './assignment_4/dao/database_sp_2')

  elsif dbtype_1 == 'nucl' and dbtpye_2 == 'prot' # First file contains a genome and the second one a proteome
    factory_sp1 = Bio::Blast.local('tblastn', "./assignment_4/dao/database_sp_1")
    factory_sp2 = Bio::Blast.local('blastx', "./assignment_4/dao/database_sp_2")

  elsif dbtype_1 == 'prot' and dbtpye_2 == 'nucl' # First file contains a proteome and the second one a genome
    factory_sp1 = Bio::Blast.local('blastx', './dao/database_sp_1')
    factory_sp2 = Bio::Blast.local('tblastn', "./assignment_4/dao/database_sp_2")

  elsif dbtype_1 == 'prot' and type_target_file == 'p' # Both files contain proteomes
    factory_sp1 = Bio::Blast.local('blastp', "./assignment_4/dao/database_sp_1")
    factory_sp2 = Bio::Blast.local('blastp', "./assignment_4/dao/database_sp_2")

  end

  puts '  ** finished Bio::Blast.local'



  # puts "\n\n\n\n"
  # puts "##################################"
  # puts "####                          ####"
  # puts "####     XXXXXXXXXXXXXXXXX    ####"
  # puts "####                          ####"
  # puts "##################################"
  # puts "\n\n"
  # #Lets create an output with the GENES that didn't have the target sequence as a record
  #
  # puts "RESULTS: ________________________________________"
  # puts ""
  # puts ""
  # puts ""
  # puts ""
  #


end



# ------------------------------------------------#
# HERE WE CALL THE FUNCTION TO INIT THE ASSIGNMENT
# ------------------------------------------------#


init_assingment

puts "Finished."

#____________________________________________________________________________________________________________________#
#

