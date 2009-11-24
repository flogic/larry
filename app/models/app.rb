class App < ActiveRecord::Base
  belongs_to :customer
  has_many   :instances
  
  validates_presence_of :name
  validates_presence_of :customer

  default_scope :order => :name
  
  before_destroy :safe_to_delete?
  
  def deployments
    instances.collect(&:deployment).compact
  end
  
  def hosts
    deployments.collect(&:host)
  end
  
  def services
    instances.collect(&:services).flatten
  end
  
  def required_services
    instances.collect(&:required_services).flatten.uniq
  end
  
  def safe_to_delete?
    instances.blank?
  end
end
