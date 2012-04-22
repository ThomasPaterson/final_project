namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    @user = make_admin
    make_sample_dashboard_post(@user.id)
    @user = make_user
    make_sample_dashboard_post(@user.id)
    make_dummy_accounts
  end

  task :init_production => :environment do
    Rake::Task['db:reset'].invoke
    make_admin
    make_user
  end
end

def make_admin
  @user = User.create!(:name => "admin",
                       :email => "example@railstutorial.org",
                       :password => "admin1",
                       :permission_level => 1,
                       :time_zone => "Pacific Time (US & Canada)")

  @admin = @user
  Dashboard.create!(:user_id => @user.id)
  
end

def make_user
  @user = User.create!(:name => "jem11",
                       :email => "jem11@sfu.ca",
                       :password => "qwerty",
                       :permission_level => 2,
                       :time_zone => "Pacific Time (US & Canada)",
                       :fname => "June",
                       :lname => "M")

  Dashboard.create!(:user_id => @user.id)
end

def make_dummy_accounts
  99.times do |n|
    name  = "User#{n+1}"
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    @user = User.create!(:name => name,
                 :email => email,
                 :password => password,
                 :permission_level => 2,
                 :time_zone => "Central Time (US & Canada)")
    
    Dashboard.create!(:user_id => @user.id)
  end
end

def make_sample_dashboard_post(user)
  20.times do |n|
    content = Faker::Lorem.sentence(5)
    Post.create!(:content => content,
                 :user_id => user.id,
                 :dashboard_id => @user.dashboard.id)
  end
end