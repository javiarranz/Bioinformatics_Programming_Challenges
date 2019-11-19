require 'rest-client'
require 'bio'
require 'net/http'
require './assignment_3/lib/rest/EbiDbfetchRestApi'
require './assignment_3/lib/file_parser'
require './assignment_3/models/Gene'

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

  path_fixtures = './assignment_3/fixtures'
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
  puts "\t\t ** Finding exons.."
  # Routine that given the Bio:EMBL object returns a hash in which the keys are
  # the coordinates of the target's matches inside exons.

  length = sequence_bio.length() # Length of the nucleotide sequence
  target_hash_positions_in_exon = {} # Hash that will contain the positions targeted inside exons as keys and the strand as values

  forward = sequence_bio.gsub(/#{@target}/).map { Regexp.last_match.begin(0) }
  reverse = sequence_bio.complement.gsub(/#{@target}/).map { Regexp.last_match.begin(0) }

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
      #
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
  puts "\t\t\t\t - finding the the CTTCTT sequence.."
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

def new_file(name_file, items_list)
  File.open("./assignment_3/outputs/" + name_file + ".gff3", "w") do |file|
    file.puts "These are the #{@gff_chr.length} chromosomes"
    items_list.each do |chromosome|
      file.puts chromosome
    end
  end
end

def get_chromosome (gene_id, sequence)
  # Here we want to find the chromosome and the position of a sequence given in the input

  bs_pa = sequence.primary_accession
  return false unless bs_pa

  chrom_array = bs_pa.split(":")
  @gff_chr.push "#{chrom_array[2]}\t.\tgene\t#{chrom_array[3]}\t#{chrom_array[4]}\t.\t+\t.\tID=#{gene_id}"
  # Here I'm pushing this new value to the array of gff_chr that later will be printed in a new file

  # We return:
  #   - Chromosome number ---> [2]
  #   - Chromosome gene start position ---> [3]
  #   - Chromosome gene end position ---> [4]
  return chrom_array[2], chrom_array[3], chrom_array[4]

end

def add_features(gene_id, targets, bioseq)
  # Method that iterates over the hash with the target's matched in exons
  # to add them as new features to the Bio:EMBL objects.

  exon_features = []

  targets.each do |target, exonid_strand|

    feat = Bio::Feature.new("target_#{@target.upcase}_exon", "#{target[0]}..#{target[1]}")

    feat.append(Bio::Feature::Qualifier.new('NA_motif', "#{@target.upcase}_in_#{exonid_strand[0]}"))
    # New feature qualifier according to https://www.ebi.ac.uk/ols/ontologies/so/terms/graph?iri=http://purl.obolibrary.org/obo/SO_0000110
    # nucleotide_motif
    # Description: A region of nucleotide sequence corresponding to a known motif.
    # Synonyms: INSDC_note:nucleotide_motif, nucleotide motif, INSDC_feature:misc_feature
    # Short id: SO:0000714 (iri: http://purl.obolibrary.org/obo/SO:0000714)
    # This format will be needed for the GFF3

    feat.append(Bio::Feature::Qualifier.new('strand', exonid_strand[1]))

    @gff_genes.push "#{gene_id}\t.\t#{feat.feature}\t#{target[0]}\t#{target[1]}\t.\t#{exonid_strand[1]}\t.\tID=#{exonid_strand[0]}"
    # We print the feature in the GFF3 gene file

    exon_features << feat
  end

  bioseq.features.concat(exon_features) # We add the new features created to the existing ones

end

def convert_to_chr(gene, targets, chromosome)
  # Given the gene ID, the hash containing the targets, and the information
  # about the chromosome, this method translates the coordinates to the ones
  # refering to the chromosome. It prints them on the GFF3 chromosome file
  targets.each do |positions, exon_strand|
    pos_ini_chr = chromosome[1].to_i + positions[0].to_i
    pos_end_chr = chromosome[1].to_i + positions[1].to_i
    @gff_chr.push "#{chromosome[0]}\t.\tNA_motif\t#{pos_ini_chr}\t#{pos_end_chr}\t.\t#{exon_strand[1]}\t.\tID=#{exon_strand[0]};parent=#{gene}"
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
  File.open("assignment_3/outputs/" + name_file + ".txt", "w") do |file|
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
        @no_targets.push(gene.gene_id)
      else
        add_features(gene.gene_id, target_hash, sequence) # We create new features and add them to each seq_obj
        chr = get_chromosome(gene.gene_id, sequence) # We return the chromosome number and postions
        convert_to_chr(gene.gene_id, target_hash, chr) # We convert the positions to the ones that correspond in the chromosome
      end
    end
  end


  #Lets create an output with the GENES that didn't have the target sequence as a record
  new_file("Genes_no_targets", @no_targets)
  new_file("Genes_targets", @gff_genes)
  new_file("Genes_chromosomes", @gff_chr)

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

  # # Create a Bio::Feature object.
  # # For example: the GenBank-formatted entry in genbank for accession M33388
  # # contains the following feature:
  # #    exon     1532..1799
  # #             /gene="CYP2D6"
  # #             /note="cytochrome P450 IID6; GOO-132-127"
  # #             /number="1"
  # feature = Bio::Feature.new('exon','1532..1799')
  # feature.append(Bio::Feature::Qualifier.new('gene', 'CYP2D6'))
  # feature.append(Bio::Feature::Qualifier.new('note', 'cytochrome P450 IID6'))
  # feature.append(Bio::Feature::Qualifier.new('number', '1'))
  #
  # # or all in one go:
  # feature2 = Bio::Feature.new('exon','1532..1799',
  #                             [ Bio::Feature::Qualifier.new('gene', 'CYP2D6'),
  #                               Bio::Feature::Qualifier.new('note', 'cytochrome P450 IID6; GOO-132-127'),
  #                               Bio::Feature::Qualifier.new('number', '1')
  #                             ])
  #
  # # Print the feature
  # puts feature.feature + "\t" + feature.position
  # feature.each do |qualifier|
  #   puts "- " + qualifier.qualifier + ": " + qualifier.value
  # end


  #CREATING NEW FEATURES
  #
  #
  #
  #
  #
  #
  # require 'bio'
  #
  # datafile2 = Bio::FlatFile.auto('At3g54340.embl')
  # entry =  datafile2.next_entry   # this is a way to get just one entry from the FlatFile
  # puts "\n\nconverting it to a Bio::Sequence"
  # bioseq = entry.to_biosequence  # this is how you convert a database entry to a Bio::Sequence
  # puts "This entry has: #{bioseq.features.length} features at the beginning"
  #
  #
  # f1 = Bio::Feature.new('myrepeat','120..124')
  # f1.append(Bio::Feature::Qualifier.new('repeat_motif', 'AAGCC'))
  # f1.append(Bio::Feature::Qualifier.new('note', 'found by repeatfinder 2.0'))
  # f1.append(Bio::Feature::Qualifier.new('strand', '+'))
  # bioseq.features << f1  # you can append features one-by-one, using the << operator of Ruby arrays
  #
  # f2 = Bio::Feature.new('myrepeat','complement(190..194)')   # NOTE THE FORMAT HERE!  See note in RED above!!!!!!!!!!
  # f2.append(Bio::Feature::Qualifier.new('repeat_motif', 'AAGCC'))
  # f2.append(Bio::Feature::Qualifier.new('note', 'found by repeatfinder 2.0'))
  # f2.append(Bio::Feature::Qualifier.new('strand', '-'))
  # bioseq.features << f2
  #
  #
  # puts "This entry has: #{bioseq.features.length} features afer appending two individual features"
  #
  # bioseq.features.concat([ f1, f2 ])   # or you can take an array of features and concatenate with the .features array
  #
  # puts "This entry has: #{bioseq.features.length} features after concatenating a list of two new features"
  #
  #   bioseq.features.each do |feature|
  #     featuretype = feature.feature
  #     next unless featuretype == "myrepeat"
  #     position = feature.position
  #     puts "\n\n\n\nFEATURE #{featuretype} @ POSITION = #{position}"
  #     qual = feature.assoc            # feature.assoc gives you a hash of Bio::Feature::Qualifier objects
  #                                     # i.e. qualifier['key'] = value  for example qualifier['gene'] = "CYP450")
  #     puts "Associations = #{qual}"
  #     # skips the entry if "/translation=" is not found
  #   end
  #
  # puts "\n\n\ndone"
  #
  #
  #
  #
  #
  #
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
end

init_assingment