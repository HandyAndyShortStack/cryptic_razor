class Sandbox < ActiveRecord::Base
  include JsonApiConcern
  belongs_to :page
  has_many :blocks
  serialize :attrs, Hash
end
