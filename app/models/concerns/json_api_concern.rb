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
      associations = self.reflect_on_all_associations
      singular = associations.select do |assoc|
        [:belongs_to, :has_one].include? assoc.macro
      end
      plural = associations.select do |assoc|
        [:has_many, :has_and_belongs_to_many].include? assoc.macro
      end
      { singular: singular.map(&:name), plural: plural.map(&:name) }
    end
  end

  def to_json_api
    _id = self.respond_to?(:uuid) ? self.uuid : self.id
    _attrs = self.respond_to?(:attrs) ? self.attrs : Hash.new
    HashWithIndifferentAccess.new({
      self.class.to_s.underscore.pluralize => [
        {
          id: _id
        }.merge(api_attr_hash).merge(_attrs).merge(json_api_links)
      ]
    })
  end

  def json_api_links
    links = {}
    linked_records = self.class.linked_records
    linked_records[:singular].each do |sym|
      links[sym] = self.send(sym).to_json_api_link
    end
    linked_records[:plural].each do |sym|
      links[sym] = self.send(sym).map &:to_json_api_link
    end
    links.empty? ? {} : { links: links }
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
