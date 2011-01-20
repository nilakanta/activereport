class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  field :name
  validates_presence_of :name
  validates_uniqueness_of :name, :email, :case_sensitive => false
  validates_format_of :email, :with => /@#{COMPANY_NAME}.com/, :message => "should belong to #{COMPANY_NAME}.com"
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
end

