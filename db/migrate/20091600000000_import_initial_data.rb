require 'active_record/fixtures'

class ImportInitialData < ActiveRecord::Migration
  def self.up
    Fixtures.create_fixtures('test/fixtures', :m_action_targets)
    Fixtures.create_fixtures('test/fixtures', :m_action_groups)
    Fixtures.create_fixtures('test/fixtures', :m_actions)
    Fixtures.create_fixtures('test/fixtures', :m_apps)
    Fixtures.create_fixtures('test/fixtures', :m_app_auths)
    Fixtures.create_fixtures('test/fixtures', :m_bbs_settings)
    Fixtures.create_fixtures('test/fixtures', :m_blog_settings)
    Fixtures.create_fixtures('test/fixtures', :m_cabinet_settings)
    Fixtures.create_fixtures('test/fixtures', :m_calendars)
    Fixtures.create_fixtures('test/fixtures', :m_companies)
    Fixtures.create_fixtures('test/fixtures', :m_kbns)
    Fixtures.create_fixtures('test/fixtures', :m_menus)
    Fixtures.create_fixtures('test/fixtures', :m_menu_auths)
    Fixtures.create_fixtures('test/fixtures', :m_notice_settings)
    Fixtures.create_fixtures('test/fixtures', :m_orgs)
    Fixtures.create_fixtures('test/fixtures', :m_places)
    Fixtures.create_fixtures('test/fixtures', :m_positions)
    Fixtures.create_fixtures('test/fixtures', :m_user_attributes)
    Fixtures.create_fixtures('test/fixtures', :m_user_belongs)
    Fixtures.create_fixtures('test/fixtures', :m_users)
  end

  def self.down

  end
end
