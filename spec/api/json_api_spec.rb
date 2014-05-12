require "spec_helper"
 
models = [User, Site, Page, Sandbox]

models.each do |model|
  describe model do
    describe "#to_json_api" do
      it "returns the expected output" do
        instance = model.new
        json = load_json model.to_s.underscore.to_sym

        expect(instance.to_json_api).to eq(json)
      end
    end
  end
end
