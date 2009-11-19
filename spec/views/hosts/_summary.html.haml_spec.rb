require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/hosts/summary' do
  before :each do
    @host = Host.generate!
  end

  def do_render
    render :partial => '/hosts/summary', :locals => { :host => @host }
  end

  it 'should display the name of the host' do
    do_render
    response.should have_text(Regexp.new(@host.name))
  end
  
  it 'should link the host name to the host show page' do
    do_render
    response.should have_tag('a[href=?]', host_path(@host), :text => @host.name)
  end
end
