require 'rest-client'
require 'bio'
require './assignment_3/lib/rest/EbiDbfetchRestApi'
require './assignment_3/lib/file_parser'
require './assignment_3/models/Gene'

#@file_name = 'ArabidopsisSubNetwork_GeneList.tsv'
@file_name = 'ArabidopsisSubNetwork_GeneList_test.tsv'
@ebi_api = EbiDbfetchRestApi.new
@target = "cttctt"
@target_length = @target.length

@gff_genes = []
@gff_chr = []
@no_targets = []

puts "ASSIGNMENT 3"
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#
# FIST, I CREATE AN OUTPUT WITH A SHORT SEQUENCE TAT CONTAINS CTTCTT IN 5'->3' IN BOTH STRANDS
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#

seq = Bio::Sequence::NA.new("ATATTCTTCTTACTGATTAAGAAGTCATCG")
puts seq

name_file = "20_NA_sequence"
File.open("assignment_3/outputs/" + name_file + ".txt", "w") do |file|
  file.puts seq
  file.puts seq.complement
end


# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#
# NOW I READ ALL THE GENES FROM THE LIST TO THEN SAVE THEM IN THE CLASS GENE
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#

def parse_original_file
  path_fixtures = './assignment_3/fixtures'
  @arabidopsis_genelist = FileParser.new(path_fixtures, @file_name)
end

parse_original_file
gene_rows = @arabidopsis_genelist.rows
#puts gene_rows
#
gene_rows.each do |row|
  Gene.new(row['Gene_ID'])
end


def get_gene_fasta(gene)
  ebi_appi = @ebi_api.get("ensemblgenomesgene", "fasta", gene, "raw")
  if ebi_appi
    puts "*** Getting fasta sequence for Gene #{gene}"
    entry = Bio::EMBL.new(ebi_appi)
    bioseq = entry.to_biosequence
  end
  bioseq
end

def get_exons_targets (bio_seq_object)
  # Routine that given the Bio:EMBL object returns a hash in which the keys are
  # the coordinates of the target's matches inside exons.

  len_bio_seq = bio_seq_object.length() # Length of the nucleotide sequence
  target_positions_in_exon = Hash.new # Hash that will contain the positions targeted inside exons as keys and the strand as values

  # We get the target's matches in both foward and reverse strand
  target_matches_in_seq_foward = bio_seq_object.gsub(/#{@target}/).map { Regexp.last_match.begin(0) }
  target_matches_in_seq_reverse = bio_seq_object.reverse.tr('atgc', 'tacg').gsub(/#{@target}/).map { Regexp.last_match.begin(0) }

  bio_seq_object.features.each do |feature|

    position = feature.position

    next unless (feature.feature == 'exon' && (not position =~ /[A-Z]/))
    # We look for the feature type "exon" and we ommit tras-splicing

    exon_id = feature.qualifiers[0].value.gsub('exon_id=', '') # We format the string

    if position =~ /complement/ # Exon is in reverse strand ---> (-)

      position = position.tr('complement()', '').split('..')
      position_reverse = []

      # Getting a 2 elements array containg initial and end position, we convert it to the reverse strand

      position.each do |pos|
        position_reverse.insert(0, len_bio_seq - pos.to_i) # We use insert to give the correct order of the coordinates
      end

      target_pos_in_exon = find_target_in_exon(exon_id, target_matches_in_seq_reverse, len_bio_seq, position_reverse, '-')
      # We call "find_target_in_exon" to determine which matches are inside of the exon.
      # Here, we pass to the function the matches and the positions of the exon both in the reverse strand
      if not target_pos_in_exon.nil? # If we retrieve a response, we add the targets to the hash
        target_positions_in_exon = target_positions_in_exon.merge(target_pos_in_exon)
      end


    else # Exon is in foward strand ---> (+)

      position = position.split('..') # Getting a 2 elements array containg initial and end position

      target_pos_in_exon = find_target_in_exon(exon_id, target_matches_in_seq_foward, len_bio_seq, position, '+')
      # We call "find_target_in_exon" to determine which matches are inside of the exon.
      # Here, we pass to the function the matches and the positions of the exon both in the foward strand
      if not target_pos_in_exon.nil? # If we retrieve a response, we add the targets to the hash
        target_positions_in_exon = target_positions_in_exon.merge(target_pos_in_exon)
      end

    end


  end

  return target_positions_in_exon
  # We return the hash

end

def find_target_in_exons(exon_id, target_sequence_matches, len_seq, exon_position, strand)
  target = {}

  case strand # We will check if we are working will the foward or reverse strand

  when '+' # Foward
    target_sequence_matches.each do |match_init|
      match_end = match_init + @target_length - 1
      if (match_init >= exon_position[0].to_i) && (match_init <= exon_position[1].to_i) && (match_end >= exon_position[0].to_i) && (match_end <= exon_position[1].to_i)
        # The condition is established to see whether the target is inside the exon
        target[[match_init, match_end]] = [exon_id, '+']
      end
    end

  when '-' # Reverse
    target_sequence_matches.each do |match_init|
      match_end = match_init + $len_target - 1
      if (match_init >= exon_position[0].to_i) && (match_init <= exon_position[1].to_i) && (match_end >= exon_position[0].to_i) && (match_end <= exon_position[1].to_i)
        # The condition is established to see whether the target is inside the exon
        # To work will the hipotetical positions that correspond to the foward strand, we need to convert the positions as follows
        m_end = len_seq - match_end
        m_init = len_seq - match_init
        target[[m_end, m_init]] = [exon_id, '-']

      end

    end
  end
end

def new_file(filename)
  if File.exists?(filename)
    File.delete(filename) # We remove the file in case it exits to update it
  end
  File.open(filename)
end

#TODO CHECK THIS
def add_features(gene_id, targets, bioseq)
  # Method that iterates over the hash with the target's matched in exons
  # to add them as new features to the Bio:EMBL objects.

  exon_features = []

  targets.each do |target, exonid_strand|

    feat = Bio::Feature.new("#{$target.upcase}_in_exon", "#{target[0]}..#{target[1]}")

    feat.append(Bio::Feature::Qualifier.new('nucleotide_motif', "#{$target.upcase}_in_#{exonid_strand[0]}"))
    # New feature qualifier according to https://www.ebi.ac.uk/ols/ontologies/so/terms/graph?iri=http://purl.obolibrary.org/obo/SO_0000110
    # nucleotide_motif
    # Description: A region of nucleotide sequence corresponding to a known motif.
    # Synonyms: INSDC_note:nucleotide_motif, nucleotide motif, INSDC_feature:misc_feature
    # Short id: SO:0000714 (iri: http://purl.obolibrary.org/obo/SO:0000714)
    # This format will be needed for the GFF3

    feat.append(Bio::Feature::Qualifier.new('strand', exonid_strand[1]))

    $gff_genes.puts "#{gene_id}\t.\t#{feat.feature}\t#{target[0]}\t#{target[1]}\t.\t#{exonid_strand[1]}\t.\tID=#{exonid_strand[0]}"
    # We print the feature in the GFF3 gene file

    exon_features << feat
  end

  bioseq.features.concat(exon_features) # We add the new features created to the existing ones

end

# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#
# I USE EBI API ==> TO GET TEH SEQUENCES
# ---------------------------------------------------------------------------------------------------------#
# ---------------------------------------------------------------------------------------------------------#


gene_rows.each do |row|
  gene = row['Gene_ID'].upcase
  gene_cleaned = gene.gsub("\n","")
  sequence = get_gene_fasta(gene_cleaned)
  unless sequence == nil
    target_hash = get_exons_targets(sequence)
    if target_hash.empty?
      @no_targets.push(gene_cleaned)
    else #TODO CHECK THIS
      add_features(gene, target_hash, seq_obj) # We create new features and add them to each seq_obj
      chr = get_chromosome(gene, seq_obj) # We return the chromosome number and postions
      convert_to_chr(gene, target_hash, chr) # We convert the positions to the ones that correspond in the chromosome
    end
  end
end


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
