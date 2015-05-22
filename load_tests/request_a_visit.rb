# -*- coding: utf-8 -*-
require 'ruby-jmeter'

def extract_authenticity_token
  extract name: 'csrf_token', regex: 'meta content="([^"]+)" name="csrf-token"'
end

test do
  defaults domain: 'preprod-prisonvisits.dsd.io', protocol: 'https', port: 443
  cookies policy: 'rfc2109', clear_each_iteration: true
  header name: 'Smoke-Test', value: ENV['SMOKE_TESTING_KEY']
  cache

  threads count: 10 do
    visit '/prisoner' do
      extract_authenticity_token
    end

    submit '/prisoner', {
      fill_in: {
        'utf8' => '✓',
        'authenticity_token' => '${csrf_token}',
        'prisoner[first_name]' => 'Jimmy',
        'prisoner[last_name]' => 'Harris',
        'prisoner[date_of_birth(3i)]' => '8',
        'prisoner[date_of_birth(2i)]' => '8',
        'prisoner[date_of_birth(1i)]' => '1977',
        'prisoner[number]' => 'a0000aa',
        'prisoner[prison_name]' => 'Rochester',
        'commit' => 'Continue'
      }
    }

    visit '/deferred/visitors' do
      extract_authenticity_token
    end
    
    submit '/deferred/visitors', {
      fill_in: {
        'utf8' => '✓',
        'authenticity_token' => '${csrf_token}',
        'visit[visitor][][first_name]' => 'Jack',
        'visit[visitor][][last_name]' => 'Smith',
        'visit[visitor][][date_of_birth(3i)]' => '1',
        'visit[visitor][][date_of_birth(2i)]' => '6',
        'visit[visitor][][date_of_birth(1i)]' => '1977',
        'visit[visitor][][email]' => 'visitor@example.com',
        'visit[visitor][][phone_number]' => '09998887777',
        'next' => 'Continue'
      }
    }

    visit '/deferred/slots' do
      extract_authenticity_token
      extract name: 'slot1_name', xpath: '//input[@class=SlotPicker-slot and position() = 1]/@value'
      extract name: 'slot2_name', xpath: '//input[@class=SlotPicker-slot and position() = 2]/@value'
      extract name: 'slot3_name', xpath: '//input[@class=SlotPicker-slot and position() = 3]/@value'
    end

    submit '/deferred/slots', {
      fill_in: {
        'utf8' => '✓',
        'authenticity_token' => '${csrf_token}',
        'visit[slots][][slot]' => '${slot1_name}',
        'visit[slots][][slot]' => '${slot2_name}',
        'visit[slots][][slot]' => '${slot3_name}',
        'next' => 'Continue'
      }
    }

    visit '/deferred/visit' do
      extract_authenticity_token
    end

    submit '/deferred/visit', {
      fill_in: {
        authenticity_token: '${csrf_token}'
      }
    }
  end
end.jmx


