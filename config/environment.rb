# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
StopfinderDev::Application.initialize!

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
   :address => "smtp.gmail.com",
   :port => 587,
   :domain => "stopinfo.pugetsound.onebusaway.org",
   :user_name => "stopinfo.uw@gmail.com",
   :password => "5+rapHang3rz",
   :authentication => "plain",
   :enable_starttls_auto => true
   }