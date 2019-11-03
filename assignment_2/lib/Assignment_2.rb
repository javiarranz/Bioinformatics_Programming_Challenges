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

  def initialize()
    puts "Start First Assignment"
    @ebi_api = EbiDbfetchRestApi.new
    @togo_api = TogoRestApi.new
    @psicquic_api = PsicquicRestApi.new
    @gene_database = GeneDatabase.new

    @gene_database.clean_tables()

    path_fixtures = './assignment_2/fixtures'
    @arabidopsis_genelist = FileParser.new(path_fixtures, 'test_ArabidopsisSubNetwork_GeneList.tsv')
    # @arabidopsis_genelist = FileParser.new(path_fixtures, 'ArabidopsisSubNetwork_GeneList.tsv')
    gene_rows = @arabidopsis_genelist.rows

    gene_rows.each do |row|
      @gene_database.add_gene(row['Gene_ID'])
    end
    # @gene_database.print
  end


  def exercise_1()
    puts %(\n\n** Exercise 1 **

-------------------------------------------------------------------------------------------------------------------------------------\n\n)

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
        puts "Encontrado para #{gene.gene_id} in psicquic database"
        get_interactors(psicquic_entry, gene)
        protein = @gene_database.get_protein_by_gene(gene)
        get_interactions(psicquic_entry, protein.protein_id)
        puts "Fin Gen"
      else
        puts "No Encontrado para #{gene.gene_id}"
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

  def get_annotations(kegg, go)


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
              # TODO Add Go
              # togows_entry_kegg = @togo_api.get("kegg-genes","ath:#{gene.gene_id}","pathways","json")
              # if togows_entry_kegg
              #   puts "Encontrado para #{gene.gene_id} in togows database"
              #   if togows_entry_kegg[0]
              #
              #   end
              #   puts "Fin Gen"
              # else
              #   puts "No Encontrado para #{gene.gene_id} in togows database"
              # end
              # togows_entry_go = @togo_api.get("ebi-uniprot","#{gene.gene_id}","dr","json")
              # if togows_entry_go
              #   puts "Encontrado para #{gene.gene_id} in togows database"
              #   if dataGO[0]["GO"]
              #   puts "Fin Gen"
              # else
              #   puts "No Encontrado para #{gene.gene_id} in togows database"
              # end

            else
              gene_new = @gene_database.add_gene(gene_id)
              @gene_database.add_protein(protein_id, gene_new)
            end
          end
        end
      end
    end
  end

  def get_interactions(psicquic_entry, protein_id)
    # interactions = []
    psicquic_entry['interactionList']['interaction'].each do |interaction|
      # TODO esto esta fallando con AT4G05180
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
            # #TODO Insert into Database
            protein_1 = @gene_database.get_protein(protein_name_1)
            protein_2 = @gene_database.get_protein(protein_name_2)
            @gene_database.add_ppi(protein_1, protein_2, conf_type, conf_value)
          end
        end
      end
    end
  end

  # def get go_annotations(togows_entry, gene)
  #
  # end
end

