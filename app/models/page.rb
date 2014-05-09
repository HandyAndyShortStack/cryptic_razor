class Page < ActiveRecord::Base
  belongs_to :site
  has_many :sandboxes
  serialize :attrs, Hash
end
