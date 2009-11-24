class Customer < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :apps

  default_scope :order => :name
  
  def instances
    apps.collect(&:instances).flatten
  end
  
  def deployments
    apps.collect(&:deployments).flatten
  end
  
  def hosts
    apps.collect(&:hosts).flatten
  end
  
  def services
    instances.collect(&:services).flatten
  end
  
  def required_services
    instances.collect(&:required_services).flatten
  end
  
  def safe_to_delete?
    apps.blank?
  end
end
