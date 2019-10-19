require './assignment_1/lib/file_parser'
require './assignment_1/models/geneDatabase'
require './assignment_1/models/seedDatabase'
require './assignment_1/models/HybridDatabase'
require './assignment_1/models/gene'
require './assignment_1/models/seed_stock'
require './assignment_1/models/hybrid_cross'

class Assignment1

  attr_reader :gene_information
  attr_reader :seed_stock_data
  attr_reader :cross_data
  attr_reader :new_stock_file

  attr_reader :gene_database
  attr_reader :seed_database
  attr_reader :hybrid_database

  def initialize(arguments)
    puts "Start First Assignment"
    @gene_database = GeneDatabase.new
    @seed_database = SeedDatabase.new
    @hybrid_database = HybridDatabase.new
    parse_args(arguments)
  end

  def exercise_1()
    puts "\n\n\n----------------EXERCISES------------------\n\n"
    puts "Exercice 1) 'simulate' planting 7 grams of seeds from each of the records in the seed stock genebank then you should update the genebank information to show the new quantity of seeds that remain after a planting. The new state of the genebank should be printed to a new file, using exactly the same format as the original file seed_stock_data.tsv\n\n"
    @seed_database.extract_grams(7, "24/10/2019")
    new_seed_rows = @seed_database.seed_list_serializer()
    new_seed_rows = new_seed_rows.unshift(@seed_stock_data.headers)
    new_stock_file.save_file(new_seed_rows)
  end
  #
  # def exercise_2()
  #
  # end

  def print_tables()
    @gene_database.print
    @seed_database.print
    @hybrid_database.print
  end

  private

  def parse_args(input_array)
    # Initialize variables
    gene_information = nil
    seed_stock_data = nil
    cross_data = nil
    new_stock_file = nil
    path_fixtures = './assignment_1/fixtures'
    path_output = './assignment_1/output/'

    # Iterate args
    input_array.each do |tsv_file|
      case tsv_file
      when 'gene_information.tsv'
        @gene_information = FileParser.new(path_fixtures, tsv_file)

        gene_rows = @gene_information.rows
        gene_rows.each { |row| @gene_database.add_gene(Gene.new(row['Gene_ID'], row['Gene_name'], row['mutant_phenotype'])) }

      when 'seed_stock_data.tsv'
        @seed_stock_data = FileParser.new(path_fixtures, tsv_file)
        seed_rows = @seed_stock_data.rows
        seed_rows.each do |row|
          gene = @gene_database.get_gene(row['Mutant_Gene_ID'])
          if gene == nil
            gene = Gene.new(row['Mutant_Gene_ID'], 'NEW Created', 'NEW Mutant')
          end
          @seed_database.add_seed(SeedStock.new(row['Seed_Stock'], gene, row['Last_Planted'], row['Storage'], row['Grams_Remaining']))
        end
      when 'cross_data.tsv'
        @cross_data = FileParser.new(path_fixtures, tsv_file)


        cross_data_rows = @cross_data.rows
        cross_data_rows.each do |row|
          seed_parent1 = @seed_database.get_seed(row['Parent1'])
          seed_parent2 = @seed_database.get_seed(row['Parent2'])
          @hybrid_database.add_hybrid(HybridCross.new(seed_parent1, seed_parent2, row['F2_Wild'],
                                                      row['F2_P1'], row['F2_P2'], row['F2_P1P2']))
        end
      when 'new_stock_file.tsv'
        @new_stock_file = FileParser.new(path_output, tsv_file, false)
      else
        puts "Document Not Found: #{tsv_file}"
      end
    end
  end


end
