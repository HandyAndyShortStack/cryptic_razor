class Sandbox < ActiveRecord::Base
  belongs_to :page
  has_many :blocks
  serialize :attrs, Hash
end
