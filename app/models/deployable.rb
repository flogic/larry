class Deployable < ActiveRecord::Base
  belongs_to :instance
  has_many :all_deployments, :class_name => 'Deployment'
  
  validates_presence_of :instance

  serialize :snapshot
  
  def self.deploy_from_instance(instance, params)
    create!(:instance => instance).deploy(params)
  end
  
  def deploy(params)
    Deployment.deploy_from_deployable(self, params)
  end
  
  def snapshot
    self[:snapshot] || {}
  end

  def deployments
    all_deployments.active
  end
  
  def deployed_services
    deployments.collect(&:deployed_services).flatten.uniq
  end
  
  def all_deployed_services
    all_deployments.collect(&:deployed_services).flatten.uniq
  end
  
  def hosts
    deployments.collect(&:hosts).flatten.uniq
  end
  
  def all_hosts
    all_deployments.collect(&:hosts).flatten.uniq
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