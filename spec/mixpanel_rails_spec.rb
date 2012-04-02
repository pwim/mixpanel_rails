require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ExampleController < ApplicationController
  uses_mixpanel

  def no_tracking
    render inline: "OK", layout: true
  end

  def with_tracking
    track_with_mixpanel "Register for site"
    render inline: "OK", layout: true
  end
end

class RedirectsController < ApplicationController
  uses_mixpanel

  def index
    track_with_mixpanel "Register for site"
    redirect_to action: :redirected
  end

  def redirected
    render inline: "OK", layout: true
  end
end

class DistinctIdController < ApplicationController
  uses_mixpanel distinct_id: lambda { 1 }

  def index
    render inline: "OK", layout: true
  end
end

shared_examples_for "mixpanel init" do
  it do
    page.find("script:first").text.should include('mpq.push(["init", "test_token"]);')
  end
end

shared_examples_for "without distinct id" do
  it { page.find("script:last").text.should_not include('distinct_id') }
end

shared_examples_for "with distinct id" do
  it { page.find("script:last").text.should include('mpq.push(["register", {"distinct_id":1}]);') }
end

shared_examples_for "with event" do
  it { page.find("script:last").text.should include('mpq.push(["track", "Register for site"])') }
end

feature 'mixpanel integration' do
  context 'visit page without tracking' do
    background { visit '/example/no_tracking' }
    it_should_behave_like "mixpanel init"
    it_should_behave_like "without distinct id"
  end

  context 'visit page with tracking' do
    background { visit '/example/with_tracking' }
    it_should_behave_like "mixpanel init"
    it_should_behave_like "without distinct id"
    it_should_behave_like "with event"
  end

  context 'visit page with distinct id' do
    background { visit '/distinct_id' }
    it_should_behave_like "mixpanel init"
    it_should_behave_like "with distinct id"
  end

  context 'follow redirect' do
    background { visit '/redirects' }
    it_should_behave_like "with event"
  end
end
