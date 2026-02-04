class Signup
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email_address, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :avatar

  validates :name, presence: true
  validates :email_address, presence: true
  validates :password, presence: true, confirmation: true

  attr_reader :user

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @user = create_user!
      team = create_team!
      create_membership!(team)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    promote_errors(e.record)
    false
  end

  private

  def create_user!
    User.create!(
      name: name,
      email_address: email_address,
      password: password,
      password_confirmation: password_confirmation,
      avatar: avatar
    )
  end

  def create_team!
    Team.create!(name: "#{name}'s Team")
  end

  def create_membership!(team)
    Membership.create!(user: @user, team: team, role: :owner)
  end

  def promote_errors(record)
    record.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
