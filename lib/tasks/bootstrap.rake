# Bootstrap the project

# namespace :bootstrap do

desc "Add the default users"
task :bootstrap => :environment do
  User.new(:name => "bob", :password => "bobpassword").save
  User.new(:name => "sue", :password => "sudpassword").save
  User.new(:name => "tim", :password => "timpassword").save
  User.new(:name => "pat", :password => "patpassword").save
end

#  desc "Run all bootstrapping tasks"
#  task :all => [:default_users]
# end
