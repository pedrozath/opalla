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
        end.to_json
      end

      def header(routes); end
    end

    def self.routes
      all_routes = Rails.application.routes.routes
      inspector  = ActionDispatch::Routing::RoutesInspector.new(all_routes)
      inspector.format(JsFormatter.new)
    end
  end
end