module ClassProfiler
  class Rack
    def initialize(app)
      @app  = app
    end

    def call(env)
      response = ::ClassProfiler::Benchmark.instance.start 'rack time' do
        @status, @headers, @response = @app.call(env)
      end

      ::ClassProfiler::Benchmark.instance.report('rack time')
      return response
    end
  end
end
