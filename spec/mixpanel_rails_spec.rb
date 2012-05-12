require "spec_helper"

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

class ExternalRedirectsController < ApplicationController
  uses_mixpanel

  def index
    track_with_mixpanel "Before External"
    redirect_to "http://www.example.org/external_redirects/after"
  end

  def after
    head :ok
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

  context 'follow external redirect' do
    background do
      @request_time = Time.parse("2010-09-05 12:00 UTC")
      @worker = Object.new
      class << @worker
        attr_accessor :written
        def write(s)
          @written = s
        end
        def data
          json = @written.match(/\?data=(.*)/)[1]
          JSON.load(Base64.decode64(json))
        end

        def event
          data["event"]
        end

        %w[ip token time].each do |s|
          define_method(s) do
            data["properties"][s]
          end
        end
      end
      class << Mixpanel::Tracker
        attr_accessor :worker
      end
      Mixpanel::Tracker.worker = @worker
      Timecop.freeze(@request_time) do
        visit '/external_redirects'
      end
    end

    it "should record data" do
      @worker.event.should == "Before External"
      @worker.ip.should == "127.0.0.1"
      @worker.time.should == @request_time.to_i
    end
  end
end
