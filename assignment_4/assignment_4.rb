require 'rest-client'
require 'bio'
require 'stringio'
require 'io/console'

$E_VAL = 10 ** -12
$OVERLAP = 50

@pep_filename = 'pep_javier.fa'
@tair_filename = 'TAIR10_javier'

@best_reciprical_hits = []
@number_of_BRH = 1

def convert_to_hash(file)
  path = './fixtures/'

  bio = Bio::FastaFormat.open(path + file)

  hash = Hash.new
  bio.each do |sequence|
    hash[(sequence.entry_id).to_s] = (sequence.seq).to_s
  end
  hash
end

def make_blast(filename, dbtype, output)
  path = './dao/'
  system("makeblastdb -in '#{filename}' -dbtype #{dbtype} -out '#{path}#{output}'")
end

def new_file(name_file, items_list, format)
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # FUNCTION TO CREATE A NEW FILE
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  File.open("./outputs/" + name_file + format, "w") do |file|
    file.puts "These are the ORTHOLOGS that were found in the files #{@pep_filename} and #{@tair_filename}"
    items_list.each do |list|
      file.puts list
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

  pep_hash = convert_to_hash(@pep_filename)
  tair_hash = convert_to_hash(@tair_filename)

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
    factory_sp2 = Bio::Blast.local('blastn', './dao/database_sp_2')

  elsif dbtype_1 == 'nucl' and dbtpye_2 == 'prot' # First file contains a genome and the second one a proteome
    factory_sp1 = Bio::Blast.local('tblastn', "./dao/database_sp_1")
    factory_sp2 = Bio::Blast.local('blastx', "./dao/database_sp_2")

  elsif dbtype_1 == 'prot' and dbtpye_2 == 'nucl' # First file contains a proteome and the second one a genome
    factory_sp1 = Bio::Blast.local('blastx', './dao/database_sp_1')
    factory_sp2 = Bio::Blast.local('tblastn', "./dao/database_sp_2")

  elsif dbtype_1 == 'prot' and type_target_file == 'p' # Both files contain proteomes
    factory_sp1 = Bio::Blast.local('blastp', "./dao/database_sp_1")
    factory_sp2 = Bio::Blast.local('blastp', "./dao/database_sp_2")

  end
  puts '  ** finished Bio::Blast.local'

  pep_bio = Bio::FastaFormat.open('./fixtures/' + @pep_filename)
  tair_bio = Bio::FastaFormat.open('./fixtures/' + @tair_filename)



  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # NOW I ITERATE EACH pep SEQUENCE
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  puts '    *Finding hits..'
  pep_bio.each do |sequence|

    sequence_id = (sequence.entry_id).to_s # We store the ID in search_file to later know if it is a reciprocal best hit
    report_target = factory_sp2.query(sequence)

    if report_target.hits[0] # Only if there have been hits continue.
      target_id = (report_target.hits[0].definition.match(/(\w+\.\w+)|/)).to_s # We get ID that will correspond to target_file ID
      if (report_target.hits[0].evalue <= $E_VAL) and (report_target.hits[0].overlap >= $OVERLAP) # We check the stablished parameters
        report_search = factory_sp1.query(">#{target_id}\n#{tair_hash[target_id]}")
        # We look in the hash with the previous ID to get the sequence and query the factory
        if report_search.hits[0] # Again, only continue if there have been hits
          match = (report_search.hits[0].definition.match(/(\w+\.\w+)|/)).to_s # We get the ID that will match with the ID in the search_file
          if (report_search.hits[0].evalue <= $E_VAL) and (report_search.hits[0].overlap >= $OVERLAP) # Check parameters
            if sequence_id == match # If the match and the search_file ID match, it means that this is a reciprocal best hit
              puts '        - MATCH FOUND!'
              @best_reciprical_hits.push("#{sequence_id}\t\t#{target_id}") # We write it in the output file')
              puts "          #{sequence_id}\t ==>\t#{target_id}"

              @number_of_BRH += 1
              puts "                                  TOTAL: #{@number_of_BRH}"

            end
          end
        end
      end
    end
  end



  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # FINALLY, I CREATE A NEW FILE WHERE I'M GOING TO WRITE ALL THE ORTHOLOGS
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  new_file('orthologs', @best_reciprical_hits,'.txt')



  puts "\n\n\n\n"
  puts "##################################"
  puts "####                          ####"
  puts "####     Results in file      ####"
  puts "####      orthologs.txt       ####"
  puts "####                          ####"
  puts "##################################"
  puts "\n\n"

  puts "RESULTS: ________________________________________"
  puts ""
  puts "Number of orthologs found:"
  puts "  ==> #{@number_of_BRH}"
  puts ""

end



# ------------------------------------------------#
# HERE WE CALL THE FUNCTION TO INIT THE ASSIGNMENT
# ------------------------------------------------#


init_assingment

puts "Finished."


#____________________________________________________________________________________________________________________#
#


