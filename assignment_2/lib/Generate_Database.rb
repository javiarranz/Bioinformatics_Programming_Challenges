require 'rest-client'
require './assignment_2/lib/rest/EbiDbfetchRestApi'
require './assignment_2/lib/rest/TogoRestApi'
require './assignment_2/lib/rest/PsicquicRestApi'
require './assignment_2/lib/file_parser'
require './assignment_2/dao/GeneDatabase'
require './assignment_2/models/Gene'


class Generate_database
  attr_reader :ebi_api
  attr_reader :togo_api
  attr_reader :psicquic_api
  attr_reader :arabidopsis_genelist

  attr_reader :gene_database

  def initialize(clean = false)
    puts "Start Second Assignment"
    @ebi_api = EbiDbfetchRestApi.new
    @togo_api = TogoRestApi.new
    @psicquic_api = PsicquicRestApi.new
    @gene_database = GeneDatabase.new

    if clean
      puts 'Cleaning Database...'
      @gene_database.clean_tables
    end
  end

  def create_database()
    puts %(\n\n** Introducing data into the database..
-------------------------------------------------------------------------------------------------------------------------------------\n\n)

    # Here I start reading the file with the genes (was txt, but I transformed it into tsv)

    path_fixtures = './assignment_2/fixtures'
    #@arabidopsis_genelist = FileParser.new(path_fixtures, 'test_ArabidopsisSubNetwork_GeneList.tsv')
    @arabidopsis_genelist = FileParser.new(path_fixtures, 'ArabidopsisSubNetwork_GeneList.tsv')
    gene_rows = @arabidopsis_genelist.rows

    # I create a list containing all locus gene
    gene_rows_list = []
    gene_rows.each do |row|
      gene_id = row["Gene_ID"]
      gene_rows_list.append(gene_id)
    end

    # Then I create the genes in the gene table using the function create gen and I keep all the genes in a list
    puts "*** Introducing genes into database..."
    puts "*** This might be a long process. Be patient"

    puts "\n\n\n\n"
    puts "*********************************"
    puts "**                             **"
    puts "**      ESTIMATED TIME:        **"
    puts "**                             **"
    puts "**        8 MIN 45 SEG         **"
    puts "**                             **"
    puts "*********************************"
    puts "\n\n\n\n"


    #---------------------------------------------------------#
    #---------------------------------------------------------#
    #---------------------------------------------------------#

        # Here I create the genes and introduce them into the database
        # I do this iterating the rows of the list Arabidopsis.tsv and
        # calling a function create gene that looks for the gene in togo
        # creating all the anotations of each gene

    gene_rows.each do |row|
      create_gene(row['Gene_ID'])
    end

    #---------------------------------------------------------#
    #---------------------------------------------------------#
    #---------------------------------------------------------#


        # Here I look for the psicquic entries of each gene
        # and finding all the interactors and interactions of
        # each gene, adding them to the database and creating also
        # those genes that are necessary but are not in the list Arabidopsis.tsv

    genes_list = @gene_database.get_all_genes_without_linked()



    # Psicquiq ==> I search for the information I need in the web that gives me the interactions
    begin
      genes_list.each do |gene|
        genes_list = @gene_database.get_all_genes_without_linked()
        if genes_list.length < 290        #save point to infinite interactions between genes
          psicquic_entry = @psicquic_api.get(gene.gene_id, 'xml25')
          if psicquic_entry
            puts "*** Adding interactions for Gene #{gene.gene_id}"
            #puts "\t*** Introducing interactors for #{gene.gene_id}..."
            get_interactors(psicquic_entry, gene)
            protein = @gene_database.get_protein_by_gene(gene)
            #puts "\t*** Introducing interactions for #{gene.gene_id}..."
            get_interactions(psicquic_entry, protein.protein_id)
          else
            #puts "*** Interactions not found for  Gene #{gene.gene_id}"
          end
        end
      rescue
      end
    end
  end

        # I found that when the gene list had 280 different genes, the PPI list was
        # not including new interactions and that the list was going to increase to
        # infinite, so I cut the process at 290 and use the 115 interactions that
        # are found in the ppi table of the database for the creation of the networks

  #---------------------------------------------------------#
  #---------------------------------------------------------#
  #---------------------------------------------------------#

  # EBI API ==> (not used)

  # genes_list.each do |gene|
  #   ebifetch = @ebi_api.get("ensemblgenomesgene", "embl", gene.gene_id, "raw")
  #
  #   if ebifetch
  #     puts "Encontrado para #{gene.gene_id}"
  #   else
  #     puts "No Encontrado para #{gene.gene_id}"
  #   end
  # end


  #------------------------------------------------------------------------------------------------------------>

  private

  def create_gene(gene_id, protein_name = false)
    genes_list = @gene_database.get_all_genes_without_linked
    if genes_list.length < 290
      gene = @gene_database.add_gene(gene_id)
      if gene
        if protein_name
          @gene_database.add_protein(protein_name, gene)
        end
        create_annotations(gene, protein_name)
        return gene
      end
      false
    end
  end


  def create_annotations(gene, protein_name)

    puts "*** Introducing the gene #{gene.gene_id} and its annotations..."
    togows_entry_kegg = @togo_api.get("kegg-genes", "ath:#{gene.gene_id}", "pathways", "json")
    togows_entry_kegg = JSON.parse(togows_entry_kegg)
    if togows_entry_kegg && togows_entry_kegg.length > 0
      kegg = togows_entry_kegg[0]
      kegg.each do |kegg_id, kegg_description|
        @gene_database.add_kegg(gene, kegg_id, kegg_description)
      end
    else
      puts "    - Not found #{gene.gene_id} in togows kegg-genes database"
    end
    togows_entry_go = @togo_api.get("ebi-uniprot", "#{gene.gene_id}", "dr", "json")
    togows_entry_go = JSON.parse(togows_entry_go)
    if togows_entry_go && togows_entry_go.length > 0
      if togows_entry_go[0].key?("GO")
        go_s = togows_entry_go[0]["GO"]
        go_s.each do |go|
          @gene_database.add_go(gene, go[0], go[1])
        end
      end
      if !protein_name && togows_entry_go[0].key?("IntAct")
        intAct = togows_entry_go[0]["IntAct"][0]
        intAct.each do |act|
          begin
            @gene_database.add_protein(act, gene)
          rescue
          end
        end
      end
    else
      puts "    - Not found in togows ebi-uniprot database"
    end
  end

  def get_interactors(psicquic_entry, gene)
    # Here I look for the list of interactors
    psicquic_entry['interactorList']['interactor'].each do |interactor|
      # Here I check that the organism is arath (could also be done with the taxid)
      if interactor['organism']['names']['shortLabel'] == 'arath'
        protein_id = interactor['names']['shortLabel']
        # Here I look for the gene_id that is in this web (names, alias ==> AT\dG\{5})
        # In case it finds the gene (and saves it into the variable gene_id), I check if that gene
        # corresponds to the gene id it was searching. It true, it will add the protein
        protein_alias = interactor['names']['alias']
        if protein_alias && protein_alias.respond_to?('each')
          protein_alias.each do |name|
            if name.upcase =~ /AT\dG\d{5}/
              gene_id = name.upcase
              if gene_id == gene.gene_id
                @gene_database.add_protein(protein_id, gene)
              else
                gene_new = create_gene(gene_id)
                if gene_new
                  @gene_database.add_protein(protein_id, gene_new)
                end
              end
            end
          end
        end
      end
    end
  end

  def get_interactions(psicquic_entry, protein_id)
    if psicquic_entry['interactionList']['interaction'].include? "xref"
      check_interaction(psicquic_entry['interactionList']['interaction'], protein_id)
    else
      psicquic_entry['interactionList']['interaction'].each do |interaction|
        check_interaction(interaction, protein_id)
      end
    end
  end

  def check_interaction(interaction, protein_id)
    genes_list = @gene_database.get_all_genes_without_linked
    if genes_list.length < 290
      exceptions = ["MI:0018", "MI:0397"]
      if !exceptions.include? interaction["xref"]["primaryRef"]["refTypeAc"]
        # Remove interactions detected by "two hybrib" and "two hybrid array" (too many false positives)
        proteins = interaction['names']['shortLabel'].split('-')
        # Always insert in same order ()
        # Protein_1 is the parameter and protein_2 is the other one, no matter the order
        protein_name_1 = protein_id
        protein_name_2 = proteins[0] == protein_id ? proteins[1] : proteins[0]

        if protein_name_1 != protein_name_2 # If both names are different means that is not the same protein
          conf_type = "unknown"
          conf_value = 0.0
          begin
            conf_value = interaction['confidenceList']['confidence']['value'].to_f
          rescue
            interaction['confidenceList']['confidence'].each do |conf|
              if conf['value'] =~ /\d\.\d+/
                conf_value = conf['value'].to_f
              else
                conf_type = conf['value']
              end
            end
          end
          if conf_value > 0.1
            # Confidence value to only return valuable information (value must be modified)

            genes_list = @gene_database.get_all_genes_without_linked
            # If protein_1 exists, tell me it's name
            protein_1 = @gene_database.get_protein(protein_name_1)
            # If protein_1 does not exist, go to Togows and look for the name
            if !protein_1
              protein_1 = get_protein(protein_name_1)
            end

            # If protein_2 exists, tell me it's name
            protein_2 = @gene_database.get_protein(protein_name_2)
            if !protein_2
              protein_2 = get_protein(protein_name_2)
            end
            # If protein_2 does not exist, go to Togows and look for the name
            if protein_1 && protein_2 && genes_list.length < 290
              @gene_database.add_ppi(protein_1, protein_2, conf_type, conf_value)
              # else
              #   puts "Cannot insert PPI for #{protein_name_1} and #{protein_name_2}"
              if !protein_1
                puts "- #{protein_name_1} not found"
              end
              if !protein_2
                puts "- #{protein_name_2} not found"
              end
            end
          end
        end
      end
    end
  end

  def get_protein(protein_name)
    genes_list = @gene_database.get_all_genes_without_linked
    if genes_list.length < 290
      protein = false
      togows_gene_db = @togo_api.get("ebi-uniprot", "#{protein_name}", "gn", "json")
      togows_gene_db = JSON.parse(togows_gene_db)
      if togows_gene_db.length > 0
        togows_gene = togows_gene_db[0][0]
        gene_id = togows_gene['loci'][0].upcase
        gene = @gene_database.get_gene(gene_id)
        if !gene
          gene = create_gene(gene_id, protein_name)
        end
        if gene
          protein = @gene_database.add_protein(protein_name, gene)
        end
      end
      protein
    end
  end


end

