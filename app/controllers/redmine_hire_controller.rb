class RedmineHireController < ApplicationController
  unloadable

  def refusal_response
    @issue = Issue.find(params[:id])
    Hh::ApiService.new.send_refusal(@issue.id)
    redirect_to @issue
  end

  def init_sidekiq_jobs
    hash = {
      'hh_api_sync_responses' => {
        'class' => 'HhApiWorker',
        'cron'  => Setting.plugin_redmine_hire['hh_api_sync_cron']
      }
    }

    Sidekiq::Cron::Job.load_from_hash hash

    redirect_to '/settings/plugin/redmine_hire'
  end

  def destroy_sidekiq_jobs
    Sidekiq::Cron::Job.destroy 'hh_api_sync_responses'
    redirect_to '/settings/plugin/redmine_hire'
  end

  def oauth
    if Hh::OAuth.fetch_tokens(params[:code])
      flash[:notice] = I18n.t('redmine_hire.settings.auth_success')
      redirect_to controller: 'settings', action: 'plugin', id: 'redmine_hire'
    else
      render_403(message: I18n.t('redmine_hire.settings.auth_fail'))
    end
  end
end
