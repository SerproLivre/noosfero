require File.dirname(__FILE__) + '/../test_helper'

class PersonNotifierTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    Person.destroy_all
    @admin = create_user('adminuser').person
    @member = create_user('member').person
    @admin.notification_time = 24
    @member.notification_time = 24
    @admin.save!
    @member.save!
    @community = fast_create(Community)
    @community.add_member(@admin)
    @article = fast_create(TextileArticle, :name => 'Article test', :profile_id => @community.id, :notify_comments => true)
    Delayed::Job.destroy_all
  end

  should 'deliver mail to community members' do
    @community.add_member(@member)
    notify
    sent = ActionMailer::Base.deliveries.first
    assert_equal [@member.email], sent.to
  end

  should 'do not send mail if do not have notifications' do
    @community.add_member(@member)
    ActionTracker::Record.delete_all
    notify
    assert ActionMailer::Base.deliveries.empty?
  end

  should 'do not send mail to people not joined to community' do
    Comment.create!(:author => @admin, :title => 'test comment 2', :body => 'body 2!', :source => @article)
    notify
    sent = ActionMailer::Base.deliveries.first
    assert !sent
  end

  should 'display author name in delivered mail' do
    @community.add_member(@member)
    Comment.create!(:author => @admin, :title => 'test comment', :body => 'body!', :source => @article)
    ActionTracker::Record.all.map{|action| Person.notify_activity(action)}
    notify
    sent = ActionMailer::Base.deliveries.first
    assert_match /#{@admin.name}/, sent.body
  end

  should 'do not include comment created before last notification' do
    @community.add_member(@member)
    ActionTracker::Record.delete_all
    comment = Comment.create!(:author => @admin, :title => 'test comment', :body => 'body!', :source => @article )
    @member.last_notification = DateTime.now + 1.day
    notify
    assert ActionMailer::Base.deliveries.empty?
  end

  should 'update last notification date' do
    Comment.create!(:author => @admin, :title => 'test comment 2', :body => 'body 2!', :source => @article)
    @community.add_member(@member)
    assert_equal nil, @member.last_notification
    notify
    assert @member.last_notification
  end

  should 'reschedule after notification' do
    Comment.create!(:author => @admin, :title => 'test comment 2', :body => 'body 2!', :source => @article)
    @community.add_member(@member)
    assert_equal nil, @member.last_notification
    notify
    assert PersonNotifier::NotifyJob.find(@member.id)
  end

  should 'schedule next mail at notification time' do
    @member.notification_time = 12
    @member.notifier.schedule_next_notification_mail
    assert_equal @member.notification_time, ((Delayed::Job.first.run_at - DateTime.now)/1.hour).round
  end

  should 'do not schedule duplicated notification mail' do
    @member.notification_time = 12
    @member.notifier.schedule_next_notification_mail
    @member.notifier.schedule_next_notification_mail
    assert_equal 1, Delayed::Job.count
  end

  should 'do not schedule next mail if notification time is zero' do
    @member.notification_time = 0
    @member.notifier.schedule_next_notification_mail
    assert_equal 0, Delayed::Job.count
  end

  should 'schedule next notifications for all person with notification time greater than zero' do
    @member.notification_time = 1
    @admin.notification_time = 0
    @admin.save!
    @member.save!
    PersonNotifier.schedule_all_next_notification_mail
    process_delayed_job_queue
    assert_equal 1, Delayed::Job.count
  end

  should 'do not create duplicated job' do
    PersonNotifier.schedule_all_next_notification_mail
    PersonNotifier.schedule_all_next_notification_mail
    assert_equal 1, Delayed::Job.count
  end

  should 'schedule after update and set a valid notification time' do
    @member.notification_time = 0
    @member.save!
    assert_equal 0, Delayed::Job.count
    @member.notification_time = 12
    @member.save!
    assert_equal 1, Delayed::Job.count
  end

  should 'reschedule with changed notification time' do
    @member.notification_time = 2
    @member.save!
    assert_equal 1, Delayed::Job.count
    @member.notification_time = 12
    @member.notifier.reschedule_next_notification_mail
    assert_equal 1, Delayed::Job.count
    assert_equal @member.notification_time, ((Delayed::Job.first.run_at - DateTime.now)/1.hour).round
  end

  def notify
    ActionTracker::Record.all.map{|action| Person.notify_activity(action)}
    process_delayed_job_queue
    @member.notifier.notify
  end

end
