class App < ActiveRecord::Base
  belongs_to :customer
  has_many   :instances
  
  validates_presence_of :name
  validates_presence_of :customer

  default_scope :order => :name
  
  def deployments
    instances.collect(&:deployment)
  end
  
  def hosts
    instances.collect(&:deployment).collect(&:host)
  end
  
  def services
    instances.collect(&:services).flatten
  end
  
  def required_services
    instances.collect(&:required_services).flatten.uniq
  end
end
