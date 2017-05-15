module Opalla
  class Router
    class << self
      def start
        create_route_helpers
        current_path = $$.location.pathname
        routes.each do |name, r|
          if r[:path] == current_path
            navigate_to name
            break
          end
        end
      end

      def navigate_to(route_key, *params)
        route = routes[route_key.to_s]
        controller_name, action = route[:reqs].split('#')
        controller              = set_controller(controller_name)
        url                     = set_url(route[:path])
        history_push(url)
        controller.new action, params
      end

      def create_route_helpers
        a = ApplicationComponent
        routes.each do |name, r|
          unless name.blank?
            args = extract_args(r[:path])
            a.define_method "#{name}_path" do
              Router.solve_route(r[:path], *args)
            end
          end
        end
      end

      def extract_args(raw_path)
        []
      end

      def solve_route(raw_path, *args)
        # raw_path.gsub %r{:(.*)/}
        raw_path
      end

      def url_for(path)
        [window.location.origin, path].join('/')
      end

      def set_controller(name)
        Object::const_get("#{name.camelize}Controller")
      end

      def set_url(path)
      end

      def history_push(url)
      end

      protected

      def routes
        Marshal.load($$.opalla_data)[:routes]
      end
    end
  end
end