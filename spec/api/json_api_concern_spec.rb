require "spec_helper"

describe JsonApiConcern do

  before(:all) do
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migration.create_table :api_models
    class ApiModel < ActiveRecord::Base
      include JsonApiConcern
      def id
        nil
      end
    end
  end

  after(:all) { ActiveRecord::Migration.drop_table :api_models }

  let(:model) { ApiModel.create }

  describe "#to_json_api" do

    it "returns a hash with indifferent access" do
      expect(model.to_json_api).to be_a(HashWithIndifferentAccess)
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

    context "there are linked objects" do

      before(:each) do
        ActiveRecord::Migration.create_table :other_api_models
        class OtherApiModel < ActiveRecord::Base
          include JsonApiConcern
          def id
            nil
          end
        end
      end
      after(:each) do
        Object.send :remove_const, "OtherApiModel"
        ActiveRecord::Migration.drop_table :other_api_models
      end

      let(:other_model) { OtherApiModel.create }

      it "includes singular links for belongs_to associations" do
        OtherApiModel.belongs_to :model
        other_model.stub model: model
        link = other_model.to_json_api[:other_api_models][0][:links][:model]
        expect(link).to eq(model.to_json_api_link)
      end

      it "inludes singular links for has_one associations" do
        OtherApiModel.has_one :model
        other_model.stub model: model
        link = other_model.to_json_api[:other_api_models][0][:links][:model]
        expect(link).to eq(model.to_json_api_link)
      end

      it "includes plural links for has_many associations" do
        OtherApiModel.has_many :models
        other_model.stub models: [model]
        link = other_model.to_json_api[:other_api_models][0][:links][:models]
        expect(link).to eq([model.to_json_api_link])
      end

      it "includes plural links for has_and_belongs_to_many associations" do
        OtherApiModel.has_and_belongs_to_many :models
        other_model.stub models: [model], otherapimodels_models: [model]
        link = other_model.to_json_api[:other_api_models][0][:links][:models]
        expect(link).to eq([model.to_json_api_link])
      end
    end
  end

  describe "#to_json_api_link" do

    it "returns a hash with indifferent access" do
      expect(model.to_json_api_link).to be_a(HashWithIndifferentAccess)
    end

    it "sets the id property to the database id if no uuid is present" do
      expect(model).not_to respond_to(:uuid)
      expect(model.to_json_api_link[:id]).to eq(model.id)
    end

    it "sets the id property uuid if the uuid property is present" do
      model.stub uuid: "uniqueid"
      expect(model.to_json_api_link[:id]).to eq(model.uuid)
    end
  end

  describe "::api_attr" do

    after(:each) { ApiModel.api_attrs = nil }

    it "causes the json api hash to include the specified attribute" do
      ApiModel.api_attr :api_attribute
      model.stub api_attribute: "value"
      expect(model.to_json_api[:api_models][0][:api_attribute]).to eq("value")
    end

    it "accepts an arbitrary number of attributes" do
      ApiModel.api_attr :api_attribute, :other_api_attribute
      model.stub api_attribute: "value", other_api_attribute: "value"
      expect(model.to_json_api[:api_models][0][:api_attribute]).to eq("value")
      expect(model.to_json_api[:api_models][0][:other_api_attribute]).to eq("value")
    end
  end

  describe "::parse_attributes" do

    before :each do
      ApiModel.any_instance.stub respond_to?: true
      ApiModel.api_attr :api_attribute
    end
    after(:each) { ApiModel.api_attrs = nil }

    let(:input) do
      {
        id: "95f67ab7-92a8-4e02-8e10-af67880f1196",
        api_attribute: "db value",
        attrs_attribute: "serialized value"
      }
    end
    let(:output) { ApiModel.parse_attributes input }

    it "returns a hash with indifferent access" do
      expect(output).to be_a(HashWithIndifferentAccess)
    end

    it "sets id of input to uuid of output if the model has a uuid column" do
      expect(output[:uuid]).to eq(input[:id])
    end

    it "sets api_attr attributes on the top level of the hash" do
      expect(output[:api_attribute]).to eq(input[:api_attribute])
    end

    it "puts the rest in the attrs hash if the model includes one" do
      expect(output[:attrs]).to eq({"attrs_attribute" => "serialized value"})
    end
  end
end
