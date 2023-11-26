# frozen_string_literal: true

# ユーザーに関してのクラス
class User < ApplicationRecord
  has_secure_password
  validates :user_name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  # validates :uid, presence: true, uniqueness: true
end
