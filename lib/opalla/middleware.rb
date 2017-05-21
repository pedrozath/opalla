class OpallaMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    s, h, r = @app.call(env)
    return [s, h, r] unless h['Content-Type'] =~ %r{text/html}
    html = r.body.gsub("<body>", "<body>#{js_routes}")
    [s, h, [html]]
  end

  def js_routes
    <<~JS
      <script>
        window.opalla_data = #{ Opalla::Util.data_dump.to_json }
      </script>
    JS
  end
end
