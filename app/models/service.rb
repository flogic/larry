class Service < ActiveRecord::Base
  include NormalizeNames

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :requirements  
  has_many :instances, :through => :requirements
  
  has_many :source_edges, :class_name => 'Edge', :foreign_key => 'source_id'
  has_many :target_edges, :class_name => 'Edge', :foreign_key => 'target_id'
  has_many :depends_on_edges, :class_name => 'Edge', :foreign_key => 'source_id'
  has_many :depends_on, :through => :depends_on_edges, :source => :target
  has_many :dependent_edges, :class_name => 'Edge', :foreign_key => 'target_id'  
  has_many :dependents, :through => :dependent_edges, :source => :source
  
  def configuration_name
    normalize_name(name)
  end

  def customers
    instances.collect(&:customer)
  end
  
  def apps
    instances.collect(&:app)
  end
  
  def deployments
    instances.collect(&:deployment)
  end
  
  def hosts
    instances.collect(&:host).compact
  end
  
  def root?
    dependents.empty?
  end
  
  def leaf?
    depends_on.empty?
  end
  
  def all_depends_on
    candidates, results, seen = depends_on.dup, [], {}
    while !candidates.empty?
      current = candidates.shift
      unless seen[current]
        results << current 
        candidates += current.depends_on
        seen[current] = true
      end
    end
    results
  end
  
  def all_dependents
    candidates, results, seen = dependents.dup, [], {}
    while !candidates.empty?
      current = candidates.shift
      unless seen[current]
        results << current 
        candidates += current.dependents
        seen[current] = true
      end
    end
    results
  end
  
  # this is going to be painful, at some point, but premature optimization is the root of all evil
  def unrelated
    Service.all - all_depends_on - all_dependents - [ self ]
  end
end
