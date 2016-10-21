namespace :deploy do
  task :deploy do
    system "dotenv s3_website push"
  end
end

namespace :build do
  task :clean do
    system "jekyll clean"
  end

  task :build do
    system "jekyll build"
  end
end

task :build => ["build:clean", "build:build"]

task :deploy => [:build, "deploy:deploy"]

task :default => :deploy
