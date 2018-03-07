class HhApiWorker
  include Hh::Worker

  def perform(*args)
    Hh::ApiService.new.execute('active')
  end
end
