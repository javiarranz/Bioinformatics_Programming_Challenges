require 'bio'


class Generate_database
  puts "Start Third Assignment"

  attr_reader :arabidopsis_genelist

  attr_reader :original_genes

  def initialize(clean = false)
    puts "Start Second Assignment"
    @gene_database = GeneDatabase.new
    @original_genes = []

    @file_name = 'ArabidopsisSubNetwork_GeneList.tsv'
    puts @file_name
    parse_original_file

  end

  #------------------------------------------------------------------------------------------------------------>

  private

  def parse_original_file
    path_fixtures = './fixtures'
    @arabidopsis_genelist = FileParser.new(path_fixtures, @file_name)
  end


end



