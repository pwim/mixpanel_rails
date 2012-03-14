require "mixpanel_rails/version"
require 'mixpanel'

module MixpanelRails
  class Railtie < Rails::Railtie
    config.mixpanel_rails = ActiveSupport::OrderedOptions.new
    config.mixpanel_rails.middleware = Mixpanel::Tracker::Middleware
    initializer 'mixpanel_rails' do |app|
      app.middleware.use app.config.mixpanel_rails.middleware, app.config.mixpanel_rails.token, :async => true
      ActiveSupport.on_load :action_controller do
        self.class.send :include, ClassMethods
      end
    end
  end

  module ClassMethods
    def uses_mixpanel(args = {})
      cattr_accessor :mixpanel_distinct_id, :mixpanel_name_tag
      self.mixpanel_distinct_id = args[:distinct_id] || lambda {}
      self.mixpanel_name_tag = args[:name_tag] || lambda {}
      include MixpanelRails::InstanceMethods
      after_filter :process_mixpanel_queue
    end
  end

  module InstanceMethods
    def track_with_mixpanel(s)
      mixpanel_queue << s
    end

    def process_mixpanel_queue
      unless response.redirect_url && request.host == URI.parse(response.redirect_url).host
        mixpanel = Mixpanel::Tracker.new(MixpanelRails::Railtie.config.mixpanel_rails.token, request.env, true)
        distinct_id = mixpanel_distinct_id.bind(self).call
        params = {:distinct_id => distinct_id}.merge(register_with_mixpanel)
        if request.env["Rack-Middleware-PDFKit"] || response.redirect_url
          mixpanel_queue.each {|s| mixpanel.track_event(s, params) }
        else
          name_tag = mixpanel_name_tag.bind(self).call
          mixpanel.append_api(:register, params)
          mixpanel.append_api(:name_tag, name_tag) if name_tag
          mixpanel_queue.each {|s| mixpanel.append_api :track, s }
        end
        session.delete :register_with_mixpanel
        session.delete :mixpanel_queue
      end
    end

    def register_with_mixpanel
      session[:register_with_mixpanel] ||= {}
    end

    def mixpanel_queue
      session[:mixpanel_queue] ||= []
    end
  end
end
