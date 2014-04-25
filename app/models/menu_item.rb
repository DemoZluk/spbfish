class MenuItem < ActiveRecord::Base
  belongs_to :parent, class_name: 'MenuItem'
  has_many :children, -> {where{published}}, class_name: 'MenuItem', foreign_key: :parent_id

  scope :primary, -> {where(parent_id: nil)}
  scope :all_published, -> {where{published}}

  validates :title, presence: true
  validates :permalink, presence: true, if: 'parent.present? && published?'

  validate :check_pid


  def check_pid
    errors.add(:parent_id, I18n.t('errors.menu_item.cannot_be_parent_of_self')) if parent_id == id && id != nil
  end
end
