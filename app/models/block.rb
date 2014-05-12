class Block < ActiveRecord::Base
  include JsonApiConcern
  belongs_to :sandbox
  serialize :attrs, Hash
end
