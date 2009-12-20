module InstancesHelper
  def options_for_deployables(deployables)
    options_for_select([['Create a new snapshot', '']] + 
      deployables.sort_by {|d| -d.last_deployment_time.to_i }.
      collect {|d| [ "'#{d.last_deployment_reason}' -- last deployed at #{d.last_deployment_time}", d.id] })
  end
end