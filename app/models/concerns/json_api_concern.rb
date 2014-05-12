module JsonApiConcern
  extend ActiveSupport::Concern

  included do
    cattr_accessor :api_attrs
  end

  module ClassMethods
    
    def api_attr *args
      self.api_attrs = args
    end

    def linked_records
      self.reflect_on_all_associations.map(&:name).uniq
    end
  end

  def to_json_api
    _id = self.respond_to?(:uuid) ? self.uuid : self.id
    _attrs = self.respond_to?(:attrs) ? self.attrs : Hash.new
    HashWithIndifferentAccess.new({
      self.class.to_s.underscore.pluralize => [
        {
          id: _id
        }.merge(api_attr_hash).merge(_attrs)
      ]
    })
  end

  def to_json_api_link
    _id = self.respond_to?(:uuid) ? self.uuid : self.id
    HashWithIndifferentAccess.new({ id: _id })
  end

  def api_attr_hash
    return {} unless self.class.api_attrs
    self.class.api_attrs.reduce(Hash.new) { |a, b| a[b] = self.send(b); a }
  end
end
