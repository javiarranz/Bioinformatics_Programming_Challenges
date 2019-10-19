require './assignment_1/lib/file_parser'
require './assignment_1/dao/GeneDatabase'
require './assignment_1/dao/SeedDatabase'
require './assignment_1/dao/HybridDatabase'
require './assignment_1/models/Gene'
require './assignment_1/models/SeedStock'
require './assignment_1/models/HybridCross'

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
    puts %(\n\n** Exercise 1 **
Simulate' planting 7 grams of seeds from each of the records in the seed stock genebank,
then you should update the genebank information to show the new quantity of seeds that remain after a planting.
The new state of the genebank should be printed to a new file, using exactly the same format as the original file seed_stock_data.tsv
-------------------------------------------------------------------------------------------------------------------------------------\n\n)
    @seed_database.extract_grams(7, "24/10/2019")
    @seed_database.write_database(@new_stock_file, @seed_stock_data.headers)
  end

  def exercise_2()

    puts %(\n\n** Exercise 2 **
Process the information in cross_data.tsv and determine which genes are genetically-linked.
To achieve this, you will have to do a Chi-square test on the F2 cross data.
If you discover genes that are linked, this information should be added as a property of each of the genes
(they are both linked to each other).
-------------------------------------------------------------------------------------------------------------------------------------\n\n)
    @hybrid_database.calculate_chi_square
    puts "\n"
    @gene_database.print
  end

  def bonus_1()
    puts %(\n\n** Bonus 1 **
+1% if your Gene Object tests the format of the Gene Identifier and rejects incorrect formats without crashing
•	 Arabidopsis gene identifiers have the format /A[Tt]\d[Gg]\d\d\d\d\d/
•	If the identifier isn't correct, then your code should stop with a helpful error message
-------------------------------------------------------------------------------------------------------------------------------------\n\n)
    puts "\t----- SOLUTION -----"
    puts %(\t***** Performed bonus on model Gene (models/Gene.rb)
\tRegex Funcion has been improved by changing the 5 '\d' for '\d{5}')
  end

  def bonus_2()
    puts "\n\n** Bonus 2 **
+1% if you create an Object that represents your entire Seed Stock 'database'
•	the object should have a #load_from_file($seed_stock_data.tsv)
•	the object should access individual SeedStock objects based on their ID (e.g. StockDatabase.get_seed_stock('A334')
•	the object should have a #write_database('new_stock_file.tsv')
-------------------------------------------------------------------------------------------------------------------------------------\n\n"
    puts "\t----- SOLUTION -----"
    puts "\t***** Added Data Access Objects (dao folder) with objects of each tables. All are related and genes and seeds are sharing the same memory position
\tso if we change a value in one database dao model, it will change the others"
  end

  def print_tables()
    @gene_database.print
    @seed_database.print
    @hybrid_database.print
  end

  private

  def parse_args(input_array)
    # Initialize variables
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
          seed_parent1 = @seed_database.get_seed_stock(row['Parent1'])
          seed_parent2 = @seed_database.get_seed_stock(row['Parent2'])
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
