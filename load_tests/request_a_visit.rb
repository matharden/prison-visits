# -*- coding: utf-8 -*-
require 'ruby-jmeter'

test do
  defaults domain: 'preprod-prisonvisits.dsd.io', protocol: 'https', port: 443
  cookies policy: 'rfc2109', clear_each_iteration: true
  cache

  threads count: 2 do
    visit '/prisoner' do
      extract name: 'csrf_token', regex: 'meta content="(.+?)" name="csrf-token"'
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
        'prisoner[prison_name]' => 'Cardiff',
        'commit' => 'Continue'
      }
    }

    visit '/deferred/visitors' do
      extract name: 'csrf_token', regex: 'meta content="(.+?)" name="csrf-token"'
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
        'next': 'Continue'
        
      }
    }

    visit '/deferred/slots' do
      extract name: 'csrf_token', regex: 'meta content="(.+?)" name="csrf-token"'
    end

    submit '/deferred/slots', {
      fill_in: {
        'utf8' => '✓',
        'authenticity_token' => '${csrf_token}',
        'visit[slots][][slot]' => 'lol',
        'visit[slots][][slot]' => 'lol',
        'visit[slots][][slot]' => 'lol',
        'next': 'Continue'
      }
    }
  end
end.jmx
