class Order < ApplicationRecord

  has_many :logs, class_name: "AuditLog", as: :source

  belongs_to :pair
  belongs_to :position, optional: true

  validates :pair_id, presence: true
  validates :direction, presence: true
  validates :size, presence: true
  validates :entry, presence: true

  def ig_sync
    IgSyncOrderJob.perform_later(id)
  end

end
