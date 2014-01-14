Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '215070675343543', '164cc1e2027376da996144a141622b69'
  provider :google_oauth2, '231209521016.apps.googleusercontent.com', 'xg5w--AklOWuICMR0UuIG-n8'
end