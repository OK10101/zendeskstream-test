class Ticket < ApplicationRecord
  scope :imported, -> () { where(imported: true) }
  scope :not_imported, -> () { where(imported: false) }
end