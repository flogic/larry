begin
  require 'vlad'
  require 'vlad_monkey_patch'
  Vlad.load :scm => :git
rescue LoadError
  # do nothing
end

namespace :vlad do
  desc "concatenate deployment commands."
  task :my_deploy do
    deploy_to = (ENV['to'].blank? ? 'staging' : ENV['to'])
    system("rake vlad:update vlad:migrate vlad:start vlad:cleanup to=#{deploy_to}")
  end    
end
