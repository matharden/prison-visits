require 'capybara/poltergeist'
require 'rspec/expectations'

class SmokeTest
  include Capybara::DSL
  include RSpec::Matchers

  PRISON_EMAIL = 'pvb.cardiff@maildrop.dsd.io'
  VISITOR_EMAIL = 'test@digital.justice.gov.uk'

  def run
    with_custom_config
    run_internal
  rescue StandardError => e
    pp e
    pp e.backtrace
    save_screenshot('error.png', full: true)
  end

  private
  def run_internal
    visit '/prisoner'
    enter_prisoner_information
    continue
    
    expect(page).to have_content('Visitor 1')

    enter_visitor_information
    continue

    expect(page).to have_content('When do you want to visit?')

    select_bookable_slot
    continue

    expect(page).to have_content('Check your request')
    
    clear_mailbox_for(PRISON_EMAIL)
    clear_mailbox_for(VISITOR_EMAIL)

    click_button 'Send request'

    expect(last_message_for(PRISON_EMAIL).subject).to match(/Visit request for Jimmy Harris on/)
    expect(last_message_for(VISITOR_EMAIL).subject).to match(/Not booked yet: we've received your visit request for/)

    visit find_staff_link(last_message_for(PRISON_EMAIL))
    find(:css, '#confirmation_outcome_slot_0').click
    fill_in 'confirmation[vo_number]', with: '12345678'

    clear_mailbox_for(PRISON_EMAIL)
    clear_mailbox_for(VISITOR_EMAIL)

    click_button 'Send email'

    expect(page).to have_content('Thank you')

    expect(last_message_for(PRISON_EMAIL).subject).to eq('COPY of booking confirmation for Jimmy Harris')
    expect(last_message_for(VISITOR_EMAIL).subject).to match(/Visit confirmed: your visit for .+ has been confirmed/)
  end

  def enter_prisoner_information
    fill_in 'Prisoner first name', with: 'Jimmy'
    fill_in 'Prisoner last name', with: 'Harris'
    fill_in 'prisoner[date_of_birth(3i)]', with: '1'
    fill_in 'prisoner[date_of_birth(2i)]', with: '5'
    fill_in 'prisoner[date_of_birth(1i)]', with: '1969'
    fill_in 'Prisoner number', with: 'a0000aa'
    find(:css, '.ui-autocomplete-input').set('Cardiff')
  end

  def enter_visitor_information
    fill_in "Your first name", with: 'Margaret'
    fill_in "Your last name", with: 'Smith'
    fill_in 'visit[visitor][][date_of_birth(3i)]', with: '1'
    fill_in 'visit[visitor][][date_of_birth(2i)]', with: '6'
    fill_in 'visit[visitor][][date_of_birth(1i)]', with: '1977'
    fill_in "Email address", with: VISITOR_EMAIL
    fill_in "Phone number", with: '09998887777'
  end

  def select_bookable_slot
    desired_time = Time.now + 3.days
    begin
      find(:css, desired_time.strftime("a.BookingCalendar-dateLink[data-date='%Y-%m-%d']")).click
      # Some dates are not bookable, ignore those.
      find(:css, desired_time.strftime("#date-%Y-%m-%d.is-active"))
    rescue Capybara::ElementNotFound => e
      desired_time += 1.day
      retry unless desired_time > Time.now + 30.days
    end

    within(:css, desired_time.strftime("#date-%Y-%m-%d.is-active")) do
      raise unless page.has_content?(desired_time.strftime("%A %e %B"))
    end

    evaluate_script(desired_time.strftime("$('#slot-%Y-%m-%d-1330-1500').click()"))
    evaluate_script(desired_time.strftime("$('#slot-%Y-%m-%d-1445-1545').click()"))
  end

  def continue
    click_button 'Continue'
  end

  def with_custom_config
    Capybara.current_driver = :poltergeist
    Capybara.app_host = ENV['SMOKE_HOST']
    Capybara.run_server = false
    Capybara.current_session.driver.add_header('Smoke-Test', ENV['SMOKE_TESTING_KEY'])
  end

  def clear_mailbox_for(email)
    url = [ENV['SMOKE_TEST_SMTP_API'], 'mailboxes', email].join('/')
    Curl.delete(url)
  end
  
  def last_message_for(email)
    url = [ENV['SMOKE_TEST_SMTP_API'], 'mailboxes', email, 'messages'].join('/')
    Mail::Message.new(JSON.parse(Curl.get(url).body_str).last['raw'])
  end

  def find_staff_link(message)
    html_part = message.parts.find do |part|
      part.content_type =~ /text\/html/
    end
    link = Nokogiri::XML(html_part.body.raw_source).xpath('//a').attr('href').to_s
    link.match /(\/deferred.*)/ do |m|
      return m[1]
    end
  end

  def screenshot
    save_screenshot('screen.png', full: true)
  end
end
