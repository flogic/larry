class Customer < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :apps

  default_scope :order => :name

  serialize :parameters
  
  before_destroy :safe_to_delete?
  
  def parameters
    self[:parameters] || {}
  end
  
  def instances
    apps.collect(&:instances).flatten.uniq
  end
  
  def deployables
    apps.collect(&:deployables).flatten.uniq
  end
  
  def deployments
    apps.collect(&:deployments).flatten.uniq
  end
  
  def all_deployments
    apps.collect(&:all_deployments).flatten.uniq
  end
  
  def deployed_services
    apps.collect(&:deployed_services).flatten.uniq
  end
    
  def all_deployed_services
    apps.collect(&:all_deployed_services).flatten.uniq
  end

  def hosts
    apps.collect(&:hosts).flatten.uniq
  end
  
  def all_hosts
    apps.collect(&:all_hosts).flatten.uniq
  end
  
  def services
    apps.collect(&:services).flatten.uniq
  end
  
  def safe_to_delete?
    apps.blank?
  end
end
