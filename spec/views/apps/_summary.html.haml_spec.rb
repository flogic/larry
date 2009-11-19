require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/apps/summary' do
  before :each do
    @app = App.generate!(:description => 'Test App')
  end

  def do_render
    render :partial => '/apps/summary', :locals => { :app => @app }
  end

  it 'should display the name of the app' do
    do_render
    response.should have_text(Regexp.new(@app.name))
  end
  
  it 'should link the app name to the app show page' do
    do_render
    response.should have_tag('a[href=?]', app_path(@app), :text => @app.name)
  end
  
  it 'should display the description of the app' do
    do_render
    response.should have_text(Regexp.new(@app.description))
  end
end
