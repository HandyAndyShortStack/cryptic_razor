def load_json filename
  json = JSON.parse(File.read "fixtures/#{filename}.json")
  define_method "#{filename}_json".to_sym do
    json
  end
end
