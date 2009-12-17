class Service < ActiveRecord::Base
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
  
  serialize :parameters, Array
  
  default_scope :order => 'name'
  
  before_destroy :safe_to_delete?
  
  # this is going to be painful, at some point, but premature optimization is the root of all evil
  def self.unrelated_services(*services)
    all - services.flatten
  end
  
  def parameters
    self[:parameters] || []
  end
  
  def customers
    instances.collect(&:customer)
  end
  
  def apps
    instances.collect(&:app)
  end
  
  def deployables
    instances.collect(&:deployables).flatten.uniq
  end
  
  def deployments
    instances.collect(&:deployments).flatten.uniq
  end
  
  def hosts
    instances.collect(&:hosts).flatten.uniq
  end
  
  def root?
    dependents.empty?
  end
  
  def leaf?
    depends_on.empty?
  end
  
  def edge_to(other)
    return nil unless other
    source_edges.find_by_target_id(other.id)
  end
  
  def edge_from(other)
    return nil unless other
    target_edges.find_by_source_id(other.id)
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
  
  def depends_on_tree
    depends_on.inject([]) do |list, service|
      list << service
      nested = service.depends_on_tree
      list << nested unless nested.blank?
      list
    end
  end
  
  def dependents_tree
    dependents.inject([]) do |list, service|
      list << service
      nested = service.dependents_tree
      list << nested unless nested.blank?
      list
    end
  end

  def unrelated
    self.class.unrelated_services(all_depends_on, all_dependents, self)
  end
  
  def needed_parameters
    (parameters + depends_on.collect(&:needed_parameters)).flatten.compact.uniq
  end
  
  def depends_on_additional_parameters
    depends_on.collect(&:needed_parameters).flatten.compact.uniq - parameters
  end
  
  def safe_to_delete?
    dependents.blank? and depends_on.blank? and requirements.blank?
  end
end
