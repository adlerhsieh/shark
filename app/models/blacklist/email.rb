class Blacklist::Email < ApplicationRecord

  scope :gmail, -> { where(source: "gmail") }

end
