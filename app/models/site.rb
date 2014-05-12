class Site < ActiveRecord::Base
  include JsonApiConcern
  belongs_to :user
  has_many :pages
  serialize :attrs, Hash
  api_attr :subdomain
end
