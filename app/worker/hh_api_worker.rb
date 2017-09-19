class HhApiWorker
  include Sidekiq::Worker

  def perform(*args)
    Hh::ApiService.new.execute('active')
  end
end
