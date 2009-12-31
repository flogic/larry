namespace :deploy do
  task :bounce_passenger do
    puts "restarting Passenger web server"
    Dir.chdir(RAILS_ROOT)
    system("touch tmp/restart.txt")    
  end
  
  task :create_rails_directories do
    puts "creating log/ and tmp/ directories"
    Dir.chdir(RAILS_ROOT)
    system("mkdir -p log tmp")
  end
  
  namespace :production do
    task :post_deploy => [ 'db:migrate', 'deploy:bounce_passenger' ]
    task :post_setup  => [ 'deploy:create_rails_directories' ]
  end
  
  namespace :staging do
    task :post_deploy => [ 'db:migrate', 'deploy:bounce_passenger' ]
    task :post_setup  => [ 'deploy:create_rails_directories' ]
  end
end