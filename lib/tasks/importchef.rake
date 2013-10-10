namespace :importchef do

  # environment is a rake task that loads all models
  desc "Imports chef data from CSV file"
  task :chefs => :environment do
    require 'csv'
    chefcount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/chefs.csv")) do |row|
      first_name = row[0]
      last_name = row[1]
      abbreviation = row[2]
      
      Chef.create(first_name: first_name, last_name: last_name, abbreviation: abbreviation)

      chefcount += 1
    end
    puts "Imported " + chefcount.to_s + " chefs!"
  end
end
