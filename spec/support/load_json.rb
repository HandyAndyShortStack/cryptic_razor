def load_json filename
  path = File.join Rails.root, *%w(spec support fixtures), "#{filename}.json"
  JSON.parse File.read path
end
