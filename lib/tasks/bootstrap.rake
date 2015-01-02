# Bootstrap the project

desc "Build the default users and database"
task :bootstrap => :environment do

  Rake::Task["db:migrate"].invoke

  User.new(:name => "bob", :password => "bobpassword").save
  User.new(:name => "sue", :password => "sudpassword").save
  User.new(:name => "tim", :password => "timpassword").save
  User.new(:name => "pat", :password => "patpassword").save
  User.new(:name => "bono@gmail.com", :password => "bonopassword").save
end

