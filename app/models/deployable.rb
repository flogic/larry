class Deployable < ActiveRecord::Base
  belongs_to :instance
  has_many :deployments
  
  validates_presence_of :instance

  serialize :snapshot
  
  def snapshot
    self[:snapshot] || {}
  end
  
  def deployed_services
    deployments.collect(&:deployed_services).flatten.uniq
  end
  
  def hosts
    deployments.collect(&:hosts).flatten.uniq
  end
  
  def app
    return nil unless instance
    instance.app
  end
  
  def customer
    return nil unless instance
    instance.customer
  end
  
  def services
    return nil unless instance
    instance.services
  end
end