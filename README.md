Bioinformatics Programming Challenges
=====



### **Preinstall Ruby Gems**

```
$ bundle install
```

### **Assignment 1**
###### Development started on 11 - October - 2019
###### Development finished on 19 - October - 2019 -  Merged to Master
###### First edition on 24 - October - 2019 - Changed chi_square_function
Execute Exercise with:
```
$ ruby process_database.rb  gene_information.tsv  seed_stock_data.tsv  cross_data.tsv  new_stock_file.tsv
```
On this exercise I have created:
- 3 models for simulating a real database (folder dao)
- 3 models for Genes, Seed and Hybrid (folder models)
- 1 class for managing Files (folder lib)
- 1 folder (fixtures) to save the tsv files
- 1 folder (output) to save new tsv files


### **Assignment 2**
###### Development started on 24 - October - 2019
###### Development finished on 6 - Novemver - 2019 -  Merged to Develop
Execute Exercise with:
```
$ ruby assignment_2.rb  
```
On this exercise I have created:
- A real database using SQLite 
- A class GeneDatabase to interact with the database (folder dao)
- A folder fixtures with the ArabidopsisSubNetwork_GeneList.tsv
- 3 models for Genes, Proteins and Networks (folder models)
- 1 class for generating the database (folder lib)
- 1 folder (rest) inside lib with the classes to connect with the we pages
- 1 folder (output) to save new files

Requirements:
- gem rest-client
- sqlite3
- gem 'activesupport'

### **Assignment 3**
###### Development started on 8 - November - 2019
###### Development finished on 22 - November - 2019 -  Merged to Develop
Execute Exercise with:
```
$ ruby assignment_3.rb  
```
On this exercise I have created:
- A folder fixtures with the ArabidopsisSubNetwork_GeneList.tsv
- A models for Genes (folder models)
- 1 folder (rest) inside lib with the classes to connect with the we pages (Ebi)
- 1 folder (output) to save new files and images

Requirements:
- gem rest-client

### **Assignment 4**
###### Development started on 28 - November - 2019
###### Development finished on 6 - December - 2019 -  Merged to Develop
Execute Exercise with:
```
$ ruby assignment_4.rb  
```
On this exercise I have created:
- A folder fixtures with the pep and tair files
- A folder (output) to save new files and images
- A folder dao for storing the databases created with blast

Requirements: blastall
- gem install ncbi-blast-dbs
- gem install blast -v 2.2.25.RC3 --pre
- gem install bio -v 1.5.0


### **Assignment 5**
###### Development started on 13 - December - 2019
###### Development finished on 17 - December - 2019 -  Merged to Develop

### **QUERIES RESULTS**
```
Results in the README of the folder assignment_5
```

On this exercise I have created:
- A file with the final queries
- A file with all the process behind the final query


