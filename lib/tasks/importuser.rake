namespace :importuser do

  # environment is a rake task that loads all models
  desc "Imports user data from CSV file"
  task :users => :environment do
    require 'csv'
    usercount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/users.csv")) do |row|
      email = row[0]
      first_name = row[1]
      last_name = row[2]
      is_admin = row[3]
      
      user = User.create(email: email, password: 'changeme', password_confirmation: 'changeme',
                         first_name: first_name, last_name: last_name, 
                         role: (is_admin == 'true' ? :admin : :user).to_s)
      user.generate_token(:auth_token)
      user.save

      usercount += 1
    end
    puts "Imported " + usercount.to_s + " Users!"
  end
end
