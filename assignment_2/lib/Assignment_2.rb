require 'rest-client'
require './assignment_2/lib/rest/EbiDbfetchRestApi'
require './assignment_2/lib/rest/TogoRestApi'
require './assignment_2/lib/rest/PsicquicRestApi'
require './assignment_2/lib/file_parser'
require './assignment_2/dao/GeneDatabase'
require './assignment_2/models/Gene'


class Assignment2
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
    puts %(\n\n** Introducing data into the database
-------------------------------------------------------------------------------------------------------------------------------------\n\n)
    path_fixtures = './assignment_2/fixtures'
    # @arabidopsis_genelist = FileParser.new(path_fixtures, 'test_ArabidopsisSubNetwork_GeneList.tsv')
    @arabidopsis_genelist = FileParser.new(path_fixtures, 'ArabidopsisSubNetwork_GeneList.tsv')
    gene_rows = @arabidopsis_genelist.rows

    gene_rows.each do |row|
      create_gene(row['Gene_ID'])
    end

    genes_list = @gene_database.get_all_genes_without_linked()
    # # EBI API
    # genes_list.each do |gene|
    #   ebifetch = @ebi_api.get("ensemblgenomesgene", "embl", gene.gene_id, "raw")
    #
    #   if ebifetch
    #     puts "Encontrado para #{gene.gene_id}"
    #   else
    #     puts "No Encontrado para #{gene.gene_id}"
    #   end
    # end

    # Psicquiq
    genes_list.each do |gene|
      psicquic_entry = @psicquic_api.get(gene.gene_id, 'xml25')
      if psicquic_entry
        puts "*** START with Gene #{gene.gene_id}"
        puts "\t*** Introducing interactors for #{gene.gene_id}..."
        get_interactors(psicquic_entry, gene)
        protein = @gene_database.get_protein_by_gene(gene)
        puts "\t*** Introducing interactions for #{gene.gene_id}..."
        get_interactions(psicquic_entry, protein.protein_id)
      else
        puts "*** Interactions not found for  Gene #{gene.gene_id}"
      end

    end
  end

  # Recorrer cada entry.
  # Recorrer cada interactorList para conocer los interactors
  #     Identificar el shortLabel (Q56YA5) basandonos en el locus name (At2g13360)
  #     poner siempre el que coincida con gene_id como primero.
  #     confidenceList tiene el nivel de confianza
  #     Cada interactor tiene sus Go
  # check organism - name -shortlabel = arath
  #
  # En interactionList, interaction, names, shortlabel sale un string con amnos interactors
  #
  #


  #togofetch = @togo_api("kegg-genes", gene.gene_id)
  #gene.togo_dbfetch = togofetch
  #end


  private

  def create_gene(gene_id, protein_name = false)
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

  def create_annotations(gene, protein_name)

    puts "*** Introducing annotations for #{gene.gene_id}..."
    togows_entry_kegg = @togo_api.get("kegg-genes", "ath:#{gene.gene_id}", "pathways", "json")
    togows_entry_kegg = JSON.parse(togows_entry_kegg)
    if togows_entry_kegg && togows_entry_kegg.length > 0
      kegg = togows_entry_kegg[0]
      kegg.each do |kegg_id, kegg_description|
        @gene_database.add_kegg(gene, kegg_id, kegg_description)
      end
    else
      puts "    - Not found in togows kegg-genes database"
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
    psicquic_entry['interactorList']['interactor'].each do |interactor|
      if interactor['organism']['names']['shortLabel'] == 'arath'
        protein_id = interactor['names']['shortLabel']
        interactor['names']['alias'].each do |name|
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
    exceptions = ["MI:0018", "MI:0397"]
    if !exceptions.include? interaction["xref"]["primaryRef"]["refTypeAc"]
      # Remove interactions detected by "two hybrib" and "two hybrid array" (too many false positives)
      proteins = interaction['names']['shortLabel'].split('-')
      #Always insert in same order ()
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
          # Confidence value to only return valuable information
          # interactions.push({
          #                       "interactor_1": protein_name_1,
          #                       "interactor_2": protein_name_2,
          #                       "confidence": confidence
          #                   })
          #
          protein_1 = @gene_database.get_protein(protein_name_1)
          if !protein_1
            protein_1 = get_protein(protein_name_1)
          end
          protein_2 = @gene_database.get_protein(protein_name_2)
          if !protein_2
            protein_2 = get_protein(protein_name_2)
          end
          if protein_1 && protein_2
            @gene_database.add_ppi(protein_1, protein_2, conf_type, conf_value)
          else
            puts "Cannot insert PPI for #{protein_name_1} and #{protein_name_2}"
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

  # def get go_annotations(togows_entry, gene)
  #
  # end
  #
  def get_protein(protein_name)
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

