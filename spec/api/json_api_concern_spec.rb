require "spec_helper"

describe JsonApiConcern do

  let(:model) { ApiModel.new }

  describe "#to_json_api" do

    it "returns a hash with indifferent access" do
      expect(model.to_json_api.class).to be(HashWithIndifferentAccess)
    end

    it "sets the id property to the database id if no uuid is present" do
      expect(model).not_to respond_to(:uuid)
      expect(model.to_json_api[:api_models][0][:id]).to eq(model.id)
    end

    it "sets the id property uuid if the uuid property is present" do
      model.stub uuid: "uniqueid"
      expect(model.to_json_api[:api_models][0][:id]).to eq(model.uuid)
    end

    it "includes attributes stored in the attrs hash" do
      model.stub attrs: {key: "value"}
      expect(model.to_json_api[:api_models][0][:key]).to eq("value")
    end
  end

  describe "::api_attr" do

    it "causes the json api hash to include the specified attribute" do
      subclass = Class.new ApiModel do
        api_attr :api_attribute
      end
      subclass.stub to_s: "ApiModel"
      model = subclass.new
      model.stub api_attribute: "value"
      expect(model.to_json_api[:api_models][0][:api_attribute]).to eq("value")
    end

    it "accepts an arbitrary number of attributes" do
      subclass = Class.new ApiModel do
        api_attr :api_attribute, :other_api_attribute
      end
      subclass.stub to_s: "ApiModel"
      model = subclass.new
      model.stub api_attribute: "value", other_api_attribute: "value"
      expect(model.to_json_api[:api_models][0][:api_attribute]).to eq("value")
      expect(model.to_json_api[:api_models][0][:other_api_attribute]).to eq("value")
    end
  end
end
