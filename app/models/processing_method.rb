class ProcessingMethod < ApplicationRecord
  has_many :coffee_bean_processing_methods, dependent: :destroy
  has_many :coffee_beans, through: :coffee_bean_processing_methods

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.strip
  end
end
