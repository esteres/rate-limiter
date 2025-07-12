FactoryBot.define do
  factory :user do
    username { "username" }
    password { 'SecurePassword!@' }
  end
end
