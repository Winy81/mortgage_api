require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do

    let(:valid_attributes) { { email: 'borrower@example.com', password: 'password123', password_confirmation: 'password123' } }

    it 'is valid with a properly formatted email and secure password' do

      user = User.new(valid_attributes)
      
      expect(user).to be_valid
    end

    it 'is invalid without an email address' do

      user = User.new(valid_attributes.merge(email: nil))

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid if the email format is malformed' do

      user = User.new(valid_attributes.merge(email: 'not-an-email'))

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is invalid if the email is a duplicate' do

      User.create!(valid_attributes)

      duplicate_user = User.new(valid_attributes)
      
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end

    it 'is invalid without a password' do

      user = User.new(valid_attributes.merge(password: nil))

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'is invalid if the password is too short' do

      user = User.new(valid_attributes.merge(password: '12345', password_confirmation: '12345'))

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'is invalid if the password confirmation does not match' do

      user = User.new(valid_attributes.merge(password_confirmation: 'mismatch123'))

      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'Password Encryption' do

    it 'securely hashes and encrypts the password' do

      user = User.create!(email: 'secure@example.com', password: 'password123', password_confirmation: 'password123')
      
      expect(user.encrypted_password).not_to eq('password123')
      expect(user.valid_password?('password123')).to be true
    end
  end
end
