class Deployment < ActiveRecord::Base
  belongs_to :deployable
  has_many :deployed_services
  
  named_scope :active, lambda {
    { :conditions => [ 'start_time <= ? and (end_time is null or end_time > ?)', Time.now, Time.now ] }
  }
    
  validates_presence_of :deployable
  validates_presence_of :reason
  validates_presence_of :start_time
  
  validate :start_time_must_not_be_in_past
  validate :end_time_must_not_be_in_past
  validate :non_nil_end_time_must_follow_start_time
  
  def self.deploy_from_deployable(deployable, params)
    deployment = create!(:deployable => deployable, 
                         :start_time => params[:start_time], 
                         :reason     => params[:reason], 
                         :end_time   => params[:end_time])
    deployment_params = params.clone
    [ :start_time, :end_time, :reason].each {|key| deployment_params.delete(key) }
    deployment.deploy(deployment_params)
  end
  
  def deploy(params)
    deployable.services.collect(&:name).each do |name| 
      deployed_services.create!(params.merge(:service_name => name, :parameters => deployable.service_parameters(name))) 
    end
    deployed_services
  end
  
  def undeploy
    return false if new_record? or !active?
    update_attribute(:end_time, Time.now)
    reload.end_time
  end
  
  def hosts
    deployed_services.collect(&:host).uniq
  end
  
  def instance
    return nil unless deployable
    deployable.instance
  end
  
  def app
    return nil unless deployable
    deployable.app
  end
  
  def customer
    return nil unless deployable
    deployable.customer
  end
  
  def services
    return nil unless deployable
    deployable.services
  end
  
  def active?
    return false unless start_time
    return false if start_time > Time.now
    return false if end_time and end_time <= Time.now
    true
  end
  
  def find_conflicting_deployments_for_host(host_id)
    return [] unless deployable and instance
    @host = Host.find(host_id)
    instance.all_deployments.select {|d| d.hosts.include?(@host) and d.start_time <= self.start_time and (d.end_time.nil? or d.end_time > self.start_time) }
  end
  
  protected
  
  def start_time_must_not_be_in_past
    errors.add(:start_time, "must not be in the past") if start_time and (Time.now - start_time > 60)
  end
  
  def end_time_must_not_be_in_past
    errors.add(:end_time, "must not be in the past") if end_time and (Time.now - end_time > 60)
  end
  
  def non_nil_end_time_must_follow_start_time
    errors.add(:end_time, "must come after start time") if end_time and start_time and (end_time < start_time)
  end
end
