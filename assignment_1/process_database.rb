require './assignment_1/lib/file_parser'
require './assignment_1/models/gene'
require './assignment_1/models/hybrid_cross'
require './assignment_1/models/seed_stock'

def parse_args(input_array)
  # Initialize variables
  gene_information = nil
  seed_stock_data = nil
  cross_data = nil
  new_stock_file = nil
  path_fixtures = './assignment_1/fixtures'
  # Iterate args
  input_array.each do |tsv_file|
    case tsv_file
    when 'gene_information.tsv'
      gene_information = FileParser.new(path_fixtures, tsv_file)
    when 'seed_stock_data.tsv'
      seed_stock_data = FileParser.new(path_fixtures, tsv_file)
    when 'cross_data.tsv'
      cross_data = FileParser.new(path_fixtures, tsv_file)
    when 'new_stock_file.tsv'
      new_stock_file = FileParser.new(path_fixtures, tsv_file, false)
    else
      puts "Document Not Found: #{tsv_file}"
    end
  end

  # Return 4 File Parsers needed for Assignment 1
  return gene_information, seed_stock_data, cross_data, new_stock_file
end


def get_gen(gene_list, gene_id)
  # iterate seed_list
  gene_list.each do |gene|
    if gene.gene_id == gene_id
      return gene
    end
  end
end


def get_seed_stock(seed_list, seed_name)
  # iterate seed_list
  seed_list.each do |seed|
    if seed.seed_stock == seed_name
      return seed
    end
  end
end


# START
gene_information, seed_stock_data, cross_data, new_stock_file = parse_args(ARGV)

gene_rows = gene_information.rows
gene_list = []
gene_rows.each { |row| gene_list.push(Gene.new(row['Gene_ID'], row['Gene_name'], row['mutant_phenotype'])) }
#puts gene_list


seed_rows = seed_stock_data.rows
seed_list = []
seed_rows.each do |row|
  gene = get_gen(gene_list, row['Mutant_Gene_ID'])
  if gene == nil
    gene = Gene.new(row['Mutant_Gene_ID'], 'NEW Created', 'NEW Mutant')
  end
  seed_list.push(SeedStock.new(row['Seed_Stock'], gene, row['Last_Planted'], row['Storage'], row['Grams_Remaining']))
end
#puts seed_list


cross_data_rows = cross_data.rows
cross_list = []
cross_data_rows.each do |row|
  seed_parent1 = get_seed_stock(seed_list, row['Parent1'])
  seed_parent2 = get_seed_stock(seed_list, row['Parent2'])
  cross_list.push(HybridCross.new(seed_parent1, seed_parent2, row['F2_Wild'],
                                  row['F2_P1'], row['F2_P2'], row['F2_P1P2']))
end
#puts cross_list

puts '------------Genes Table------------'
gene_list.each { |gene| gene.print() }
puts "\n\n------------Seed Table------------"
seed_list.each { |seed| seed.print() }
puts "\n\n------------Hybrid Cross Table------------"
cross_list.each { |cross| cross.print() }

puts "\n\n\n----------------EXERCISES------------------\n\n"
puts "Exercice 1) 'simulate' planting 7 grams of seeds from each of the records in the seed stock
genebank then you should update the genebank information to show the new quantity of seeds that remain
after a planting. The new state of the genebank should be printed to a new file, using exactly the same
format as the original file seed_stock_data.tsv\n\n"

new_seed_rows = [seed_stock_data.headers]
seed_list.each do |seed|
  seed.extract_grams(7, "24/10/2019")
  new_seed_rows.push([seed.seed_stock, seed.gene.gene_id, seed.last_planted, seed.storage, seed.grams_remaining])
end


#puts new_seed_rows

#new_stock_file.save_file(new_seed_rows)

new_stock_file.save_file('./assignment_1/output/', new_seed_rows)

puts "\n\n\n\n\n"
#puts csv_str


puts "Execrise 2) 'process the information in cross_data.tsv and determine which genes are
genetically-linked. To achieve this, you will have to do a Chi-square test
on the F2 cross data. If you discover genes that are linked, this information
should be added as a property of each of the genes (they are both linked to each
other).
'"

cross_list.each do |cross|
  #puts cross.print
  cross.chi_square()
end

puts "\n\n\n\n\nfinish"


#gene_list.push(Gene.new('Test 1', 'Name 1','mutant 1'))

#gene_information.save_file("Gene_ID\tGene_name\tmutant_phenotype", [])
#gene_list.each {|gene| gene.print()}
# Do whatever with new_stock_file variable
#
#
#
#
#