namespace :importstat do

  # environment is a rake task that loads all models
  desc "Imports stat data from CSV file"
  task :stats => :environment do
    require 'csv'
    statcount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/stats.csv")) do |row|
      name = row[0]
      points = row[1].to_i
      abbreviation = row[2]
      short_name = row[3]
      ordinal = row[4].to_i

      Stat.create(name: name, abbreviation: abbreviation, short_name: short_name, points: points,
      	          ordinal: ordinal)
      statcount += 1
    end
    puts "Imported " + statcount.to_s + " stats!"
  end
end
