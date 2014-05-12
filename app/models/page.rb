class Page < ActiveRecord::Base
  include JsonApiConcern
  belongs_to :site
  has_many :sandboxes
  serialize :attrs, Hash
end
