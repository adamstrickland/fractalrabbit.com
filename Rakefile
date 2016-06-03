task :deploy => [:build] do
  %x{dotenv s3_website push}
end

task :build do
  %{jekyll build}
end
