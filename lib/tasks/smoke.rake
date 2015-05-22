require File.join(Rails.root, 'smoke_tests', 'request_and_confirm_test')

namespace :smoke do
  task :test do
    SmokeTest.new.run
  end
end
