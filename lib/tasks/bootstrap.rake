desc "Build the default users and database"

task :bootstrap => :environment do
  Rake::Task["db:migrate"].invoke
  User.new(:name => "bob", :password => "bobpassword", :profile => "premium_recording_plus").save
  User.new(:name => "sue", :password => "suepassword", :profile => "premium_recording_plus").save
  User.new(:name => "tim", :password => "timpassword", :profile => "premium_recording_plus").save
  User.new(:name => "pat", :password => "patpassword", :profile => "premium_recording_plus").save
  User.new(:name => "john", :password => "johnpassword", :profile => "premium_recording_plus").save
end

