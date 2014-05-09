class User < ActiveRecord::Base
  include JsonApiConcern
  has_many :sites
  api_attr :email
end
