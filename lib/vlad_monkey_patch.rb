module Vlad

  def self.load options = {}
    options = {:config => options} if String === options

    recipes = {
      :app    => :passenger,
      :config => 'config/deploy.rb',
      :core   => :core,
      :scm    => :svn,
      :web    => :apache,
    }.merge(options)

    recipes.each do |flavor, recipe|
      next if recipe.nil? or flavor == :config
      require "vlad/#{recipe}"
    end

    # this is the reason for the monkey-patch -- this is included in unreleased flogs
    Kernel.load "config/deploy.rb.#{ENV['to']}" if ENV['to']
  end
end
