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

    def post_from_api hsh
      self.create(parse_attributes hsh)
    end

    def put_from_api hsh
      model = find_from_api(hsh)
      model.clear_api_attributes
      model.update_attributes(parse_attributes hsh)
    end

    def patch_from_api hsh
      model = find_from_api(hsh)
      new_attrs = parse_attributes hsh
      if new_attrs[:attrs]
        new_attrs[:attrs] = model.attrs.merge(new_attrs[:attrs]) 
      end
      model.update_attributes(new_attrs)
    end

    def delete_from_api hsh
      find_from_api(hsh).destroy
    end

    def find_from_api hsh
      hsh = HashWithIndifferentAccess.new(hsh)
      if self.new.respond_to? :find_by_uuid
        self.find_by_uuid(hsh[:id])
      else
        self.find(hsh[:id])
      end
    end

    def parse_attributes hsh
      hsh = HashWithIndifferentAccess.new(hsh)
      attrs = HashWithIndifferentAccess.new
      if self.new.respond_to? :uuid && hsh[:id]
        attrs[:uuid] = hsh[:id]
      end
      hsh.delete(:id)
      if self.api_attrs
        self.api_attrs.each do |sym|
          next unless hsh[sym]
          attrs[sym] = hsh[sym]
          hsh.delete(sym)
        end
      end
      attrs[:attrs] = hsh if self.new.respond_to? :attrs
      attrs
    end
  end

  def clear_api_attributes
    self.attrs = {} if self.respond_to? :attrs
    if self.class.api_attrs
      self.class.api_attrs.each do |sym|
        self.send "#{sym}=".to_sym, nil
      end
    end
    self.save
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
    links.keys.any? { |key| links[key].any? } ? { links: links } : {} 
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
