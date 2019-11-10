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
###### Development finished on 6 - October - 2019 -  Merged to Develop
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


