class App < ActiveRecord::Base
  belongs_to :customer
  has_many   :instances
  
  validates_presence_of :name
  validates_presence_of :customer
  validates_uniqueness_of :name, :scope => :customer_id

  default_scope :order => :name
  
  serialize :parameters
  
  before_destroy :safe_to_delete?
  
  def parameters
    self[:parameters] || {}
  end
  
  def services
    instances.collect(&:services).flatten.uniq
  end
  
  def deployables
    instances.collect(&:deployables).flatten.uniq
  end
  
  def deployments
    instances.collect(&:deployments).flatten.uniq
  end
  
  def deployed_services
    instances.collect(&:deployed_services).flatten.uniq
  end
  
  def hosts
    instances.collect(&:hosts).flatten.uniq
  end
  
  def safe_to_delete?
    instances.blank?
  end
end
