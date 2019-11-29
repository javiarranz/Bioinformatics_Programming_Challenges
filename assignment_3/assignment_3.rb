require 'rest-client'
require 'bio'
require 'net/http'
require './lib/rest/EbiDbfetchRestApi'
require './lib/file_parser'
require './models/Gene'

@file_name = 'ArabidopsisSubNetwork_GeneList.tsv'
#@file_name = 'ArabidopsisSubNetwork_GeneList_test.tsv'
@ebi_api = EbiDbfetchRestApi.new
@target = Bio::Sequence::NA.new("CTTCTT")
@target_length = @target.length

@gff_genes = []
@gff_chr = []
@no_targets = []


def parse_original_file
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # NOW I READ ALL THE GENES FROM THE LIST TO THEN SAVE THEM IN THE CLASS GENE
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  path_fixtures = './fixtures'
  @arabidopsis_genelist = FileParser.new(path_fixtures, @file_name)
end

def get_gene_fasta(gene_id)
  ebi_api = @ebi_api.get("ensemblgenomesgene", "embl", gene_id, false)

  # cleaned_sequence = clean_sequence(ebi_api)
  # for fasta files to create a Bio::Sequence:NA.new(ebi_api)

  if ebi_api
    puts "*** Getting fasta sequence for Gene #{gene_id}"
    entry = Bio::EMBL.new(ebi_api)
    # entry = Bio::Sequence::NA.new(cleaned_sequence)
    return entry.to_biosequence
  end
  nil
end

def clean_sequence(ebi_api)
  ebi_api = ebi_api.split("\n")
  cleaned_sequence = ""
  ebi_api.each do |row|
    if row != "" && !row.start_with?('>')
      cleaned_sequence += row
    end
  end
  cleaned_sequence
end

def get_exons_targets(sequence_bio)
  puts "\t ** Finding exons.."
  # Routine that given the Bio:EMBL object returns a hash in which the keys are
  # the coordinates of the target's matches inside exons.

  length = sequence_bio.length() # Length of the nucleotide sequence
  target_hash_positions_in_exon = {} # Hash that will contain the positions targeted inside exons as keys and the strand as values

  forward = sequence_bio.gsub(/#{@target}/).map { Regexp.last_match.begin(0) }
  reverse = sequence_bio.complement.gsub(/#{@target}/).map { Regexp.last_match.begin(0) }
  puts "\t\t * Finding the CTTCTT sequence.."
  sequence_bio.features.each do |feature|
    #finds the position of the feature
    position = feature.position
    next unless (feature.feature == 'exon' && (not position =~ /[A-Z]/))
    # We look for the feature type "exon" and we ommit tras-splicing
    exon_id = feature.qualifiers[0].value.gsub('exon_id=', '') # We format the string
    if position =~ /complement/ # Exon is in reverse strand ---> (-)
      position = position.tr('complement()', '').split('..')
      position_reverse = []
      # Getting a 2 elements array containg initial and end position, we convert it to the reverse strand
      position.each do |pos|
        position_reverse.insert(0, length - pos.to_i) # We use insert to give the correct order of the coordinates
      end

      target_pos_in_exon = find_target_in_exons(exon_id, reverse, length, position_reverse, '-')
      # We call "find_target_in_exon" to determine which matches are inside of the exon.
      # Here, we pass to the function the matches and the positions of the exon both in the reverse strand
      if not target_pos_in_exon.nil? # If we retrieve a response, we add the targets to the hash
        target_hash_positions_in_exon = target_hash_positions_in_exon.merge(target_pos_in_exon)
      end
    else # Exon is in foward strand ---> (+)
      position = position.split('..') # Getting a 2 elements array containg initial and end position
      # position = position.map(&:to_i)  #Transform string into integer
      target_pos_in_exon = find_target_in_exons(exon_id, forward, length, position, '+')
      # We call "find_target_in_exon" to determine which matches are inside of the exon.
      # Here, we pass to the function the matches and the positions of the exon both in the foward strand
      if not target_pos_in_exon.nil? # If we retrieve a response, we add the targets to the hash
        target_hash_positions_in_exon = target_hash_positions_in_exon.merge(target_pos_in_exon)
      end

    end
  end

  target_hash_positions_in_exon # We return the hash
end

def find_target_in_exons(exon_id, target_sequence_matches, len_seq, exon_position, strand)
  target = Hash.new
# We will check if we are working will the foward or reverse strand
  if strand == '+' # Foward
    target_sequence_matches.each do |match_init|
      match_end = match_init + @target_length - 1
      if (match_init >= exon_position[0].to_i) && (match_init <= exon_position[1].to_i) && (match_end >= exon_position[0].to_i) && (match_end <= exon_position[1].to_i)
        # The condition is established to see whether the target is inside the exon
        target[[match_init, match_end]] = [exon_id, '+']
      end
    end
  elsif strand == '-' # Reverse
    target_sequence_matches.each do |match_init|
      match_end = match_init + @target_length - 1
      if (match_init >= exon_position[0].to_i) && (match_init <= exon_position[1].to_i) && (match_end >= exon_position[0].to_i) && (match_end <= exon_position[1].to_i)
        # The condition is established to see whether the target is inside the exon
        # To work will the hipotetical positions that correspond to the foward strand, we need to convert the positions as follows
        m_end = len_seq - match_end
        m_init = len_seq - match_init
        target[[m_end, m_init]] = [exon_id, '-']
      end
    end
  else
    puts "unknown strand"
  end
  return target
end

def add_features(gene_id, targets, bioseq)
  # Method that iterates over the hash with the target's matched in exons
  # to add them as new features to the Bio:EMBL objects.
  puts "\t\t\t\t - Adding new features and qualifiers"
  exon_features = []

  targets.each do |target, exonid_strand|
    feat = Bio::Feature.new("target_#{@target}_exon", "#{target[0]}..#{target[1]}")
    # Here I add the new Features nucleotide motif and strand

    feat.append(Bio::Feature::Qualifier.new('nucleotide motif', "#{@target.upcase}_in_#{exonid_strand[0]}"))
    feat.append(Bio::Feature::Qualifier.new('strand', exonid_strand[1]))
    # Here I add the new Qualifiers nucleotide motif and strand

    @gff_genes.push "#{gene_id}\t.\t#{feat.feature}\t#{target[0]}\t#{target[1]}\t.\t#{exonid_strand[1]}\t.\tID=#{exonid_strand[0]}"
    # Here I push all the values to the array gff_genes to then create the file

    exon_features << feat
  end
  bioseq.features.concat(exon_features) # We add the new features created to the existing ones
end

def get_chromosome (gene_id, sequence)
  # Here we want to find the chromosome and the position of a sequence given in the input
  puts "\t\t\t\t - Getting the positions of the chromosomes"
  sequence_pa = sequence.primary_accession
  return false unless sequence_pa

  pa_array = sequence_pa.split(":")
  # In this array we have:
  #   [0] => chromosome
  #   [1] => TAIR (arabidopsis thaliana)
  #   [2] => Chromosome number
  #   [3] => chromosome gene start position
  #   [4] => Chromosome gene end position
  #   [5] => single number (don't know what it is)

  # Lets put an example of the first gene that it finds:
  #   - [chromosome]  [TAIR10]  [5] [22038165]  [22039568]  [1]


  @gff_chr.push "#{pa_array[2]}\t.\tgene\t#{pa_array[3]}\t#{pa_array[4]}\t.\t+\t.\tID=#{gene_id}"
  # Here I'm pushing this new value to the array of gff_chr that later will be printed in a new file
  # And I return: [2][3][4]
  return pa_array[2], pa_array[3], pa_array[4]

end

def get_chr_coordinates(gene, targets, chromosome)
  # With the gene ID, the hash containing the targets, and the information about the chromosome,
  # I translate the coordinates to the ones refering to the chromosome.
  # Then I push it to the array gff_chr

  targets.each do |positions, exon_strand|
    pos_ini_chr = chromosome[1].to_i + positions[0].to_i
    pos_end_chr = chromosome[1].to_i + positions[1].to_i
    @gff_chr.push "#{chromosome[0]}\t.\tnucleotide motif\t#{pos_ini_chr}\t#{pos_end_chr}\t.\t#{exon_strand[1]}\t.\tID=#{exon_strand[0]};parent=#{gene}"
  end
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
  puts "ASSIGNMENT 3"

  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # FIRST, I CREATE AN OUTPUT WITH A SHORT SEQUENCE TAT CONTAINS CTTCTT IN 5'->3' IN BOTH STRANDS
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  seq = Bio::Sequence::NA.new("ATATTCTTCTTACTGATTAAGAAGTCATCG")
  puts seq

  name_file = "20_NA_sequence"
  File.open("outputs/" + name_file + ".txt", "w") do |file|
    file.puts seq
    file.puts seq.complement
  end


  parse_original_file
  gene_rows = @arabidopsis_genelist.rows

  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#
  # I USE EBI API ==> TO GET TEH SEQUENCES
  # ---------------------------------------------------------------------------------------------------------#
  # ---------------------------------------------------------------------------------------------------------#

  gene_rows.each do |row|
    gene = Gene.new(row['Gene_ID'])
    sequence = get_gene_fasta(gene.gene_id)
    #sequence.output
    unless sequence == nil
      target_hash = get_exons_targets(sequence)
      if target_hash.empty?
        puts "CTTCTT SEQUENCE NOT FOUND FOR #{gene.gene_id} "
        @no_targets.push(gene.gene_id)
      else
        add_features(gene.gene_id, target_hash, sequence) # We create new features and add them to each seq_obj
        chr = get_chromosome(gene.gene_id, sequence) # We return the chromosome number and positions
        get_chr_coordinates(gene.gene_id, target_hash, chr) # We convert the positions to the ones that correspond in the chromosome
      end
    end
  end

  puts "\n\n\n\n"
  puts "##################################"
  puts "####                          ####"
  puts "####   CREATING GFF3 FILES    ####"
  puts "####                          ####"
  puts "##################################"
  puts "\n\n"
  #Lets create an output with the GENES that didn't have the target sequence as a record
  new_file("Genes_no_targets", @no_targets, ".txt")
  new_file("Genes_targets", @gff_genes, ".gff3")
  new_file("Genes_chromosomes", @gff_chr, ".gff3")

  puts "RESULTS: ________________________________________"
  puts "There are #{@no_targets.length} genes that does not have the target sequence"
  puts "There are #{gene_rows.length - @no_targets.length} genes that have the target sequence "

  puts "The CTTCTT sequence has been targeted in exons #{@gff_genes.length} times"
  puts "There are #{gene_rows.length - @no_targets.length} genes with #{@gff_chr.length - (gene_rows.length - @no_targets.length)} NA_motif in Genes_chromosomes.gff3"


end



# ------------------------------------------------#
# HERE WE CALL THE FUNCTION TO INIT THE ASSIGNMENT
# ------------------------------------------------#


init_assingment

puts "Finished."