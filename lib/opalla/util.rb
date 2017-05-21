module Opalla
  module Util
    class JsFormatter
      def initialize
        @buffer = []
      end

      def result
        @buffer
      end

      def section(routes)
        @buffer = routes.each_with_object({}) do |r, memo|
          memo[r[:name]] = {
            verb: r[:verb],
            path: r[:path],
            reqs: r[:reqs]
          }
        end
      end

      def header(routes); end
    end

    class << self
      def add_vars(var_assign)
        @vars ||= {}
        @vars.merge!(var_assign)
      end

      def vars
        @vars || {}
      end

      def data_dump
        Marshal.dump(data)
      end

      def data
        {
          routes: routes,
          vars:   vars
        }
      end

      def routes
        all_routes = Rails.application.routes.routes
        inspector  = ActionDispatch::Routing::RoutesInspector.new(all_routes)
        inspector.format(JsFormatter.new)
      end
    end
  end
end