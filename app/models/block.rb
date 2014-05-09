class Block < ActiveRecord::Base
  belongs_to :sandbox
  serialize :attrs
end
