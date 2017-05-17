module Opalla
  class Router
    class << self
      def start
        current_path = $$.location.pathname
        routes.each do |name, r|
          if r.JS[:path] == current_path
            navigate_to name
            break
          end
        end
      end

      def navigate_to(route_key, *params)
        route = routes[route_key.to_s]
        controller_name, action = route.reqs.split('#')
        controller              = set_controller(controller_name)
        url                     = set_url(route.path)
        history_push(url)
        controller.new action, params
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
        @routes ||= $$.opalla_data.routes
      end
    end
  end
end