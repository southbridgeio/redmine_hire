require File.expand_path('../../test_helper', __FILE__)

class HhIssueBuilderTest < ActiveSupport::TestCase
  fixtures :issues, :projects, :trackers, :issue_statuses

  context 'execute' do

    setup do
      @user = User.new(login: 'redmine_hire', firstname: 'Name', lastname: 'Lastname')
      @user.validate
      @user.email_address.address = 'test@mail.ru'
      @user.save

      @params = {
        vacancy_id: "22242092",
        resume_id: "f88757a00003fb4920001236f26d6f676b4630",
        hh_response_id: "973246529",
        vacancy_name: "Системный администратор Linux",
        applicant_city: "Абакан",
        vacancy_city: "Абакан",
        vacancy_link: "https://hh.ru/vacancy/22242092",
        applicant_email: "akimov.rf@ya.ru",
        applicant_first_name: "Дмитрий",
        applicant_last_name: "Акимов",
        applicant_middle_name: "Николаевич",
        applicant_birth_date: "1989-10-31",
        resume_link: "https://hh.ru/resume/f88757a00003fb4920001236f26d6f676b4630?t=973246529",
        applicant_photo: nil,
        salary: 100000,
        experience: [{"industries"=>[{"id"=>"36.403", "name"=>"Государственные организации"}], "end"=>nil, "description"=>"Поддержка различных программно-технических комплексов на основе:\r\n• Операционные системы: Windows (2003-2012), Linux (Red Hat, Ubuntu).\r\n• СУБД: IBM DB2, Oracle Database, Cache InterSystems, MySQL, MSSQL.\r\n• Сервера приложений: IBM WebSphere, Apache, GlassFish, IIS, Oracle Weblogic.\r\n• Языки программирования: Знание: С#, Delphi, Опыт программирования на Java, Python Visual Basic, PHP, C/С++. Опыт работы с bash, vbs. Без проблем освою любой язык программирования.\r\n• ПО виртуализации: VMware Infrastructure (удостоверение о повышении квалификации), VirtualBox.\r\n• Опыт поддержки системы Oracle Identity Management\r\n• Система обмена сообщениями IBM WebSphere MQ\r\n• Система резервного копирования IBM TSM. \r\n• Система событийного мониторинга IBM Tivoli Monitoring\r\n• Работа с системами хранения QNAP, IBM Storvize\r\n• Настройка сетевого оборудования Cisco, Extreme Networks, 3COM.", "area"=>{"url"=>"https://api.hh.ru/areas/1187", "id"=>"1187", "name"=>"Республика Хакасия"}, "company_url"=>"http://www.pfrf.ru/", "industry"=>nil, "company_id"=>nil, "employer"=>nil, "start"=>"2012-11-01", "position"=>"Ведущий специалист-эксперт отдела информационных технологий", "company"=>"ГУ Отделение Пенсионного Фонда РФ по РХ"}, {"industries"=>[{"id"=>"48.681", "name"=>"Лечебно-профилактические учреждения"}], "end"=>"2013-04-01", "description"=>"- Поддержка работы программно-технического комплекса: \"Комплексная медицинская информационная система\" (КМИС) - IBM Lotus Domino.\r\n- Поддержка работы сети, AD, различного общесистемного и прикладного ПО.", "area"=>{"url"=>"https://api.hh.ru/areas/1187", "id"=>"1187", "name"=>"Республика Хакасия"}, "company_url"=>nil, "industry"=>nil, "company_id"=>nil, "employer"=>nil, "start"=>"2012-08-01", "position"=>"Инженер-программист", "company"=>"МБУЗ «Клинический родильный дом»"}],
        description: "• Поддержка программно-аппаратных комплексов различного уровня сложности (развертывание, настройка, обновление, обслуживание, резервное копирование и т.п.)\r\n• Опыт внедрения программно-аппаратных комплексов.\r\n• Разработка и проектирование баз данных (SQL) и программных комплексов. Анализ, проектирование, составление технического задания, разработка, внедрение.\r\n• Быстрое обучение требуемому языку программирования.\r\n• Поддержка виртуальной инфраструктуры (проектирование, развертывание, настройка, поддержка и т.п.).",
        cover_letter: "Готов работать удаленно"
      }

      Setting.stubs(:plugin_redmine_hire).returns(
        'project_name' => 'test',
        'issue_status' => 1,
        'issue_tracker' => 'test',
        'issue_author' => 'issue author'
      )
    end

    subject { Hh::IssueBuilder.new(@params).execute }

    context 'when Helpdesk present' do

      setup do
        Hh::IssueBuilder.any_instance.stubs(:helpdesk_present?).returns(true)
      end

      should 'raise error if helpdesk_api_post fail' do
        stub_request(:post, "#{Setting['protocol']}://#{Setting['host_name']}/helpdesk/create_ticket.xml")
          .to_return body: "", status: '401'

        assert_raises(Exception) { subject }
      end

      should 'assign issue attributes' do
        stub_request(:post, "#{Setting['protocol']}://#{Setting['host_name']}/helpdesk/create_ticket.xml")
          .to_return body: "Issue 2 created", status: '201'

        subject
        issue = Issue.find(2)
        status = IssueStatus.find(1)

        assert_equal @params[:vacancy_id].to_i, issue.vacancy_id
        assert_equal @params[:resume_id], issue.resume_id
        assert_equal status.id, issue.status_id
        assert_equal @user.id, issue.author_id
        assert_equal @params[:hh_response_id].to_i, issue.hh_response_id
      end

    end

    context 'when Helpdesk not present' do

      setup do
        Hh::IssueBuilder.any_instance.stubs(:helpdesk_present?).returns(false)
      end

      should 'raise error if redmine_api_post fail' do
        stub_request(:post, "#{Setting['protocol']}://#{Setting['host_name']}/issues.json")
          .to_return body: "", status: '401'

        assert_raises(Exception) { subject }
      end

      should 'assign issue attributes' do
        stub_request(:post, "#{Setting['protocol']}://#{Setting['host_name']}/issues.json")
          .to_return body: "{\"issue\":{\"id\":2}}", status: '201'

        subject
        issue = Issue.find(2)
        status = IssueStatus.find(1)

        assert_equal @params[:vacancy_id].to_i, issue.vacancy_id
        assert_equal @params[:resume_id], issue.resume_id
        assert_equal status.id, issue.status_id
        assert_equal @user.id, issue.author_id
        assert_equal @params[:hh_response_id].to_i, issue.hh_response_id
      end
    end
  end
end
