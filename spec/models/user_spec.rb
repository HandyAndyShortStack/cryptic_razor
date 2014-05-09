require "spec_helper"

describe User do
  
  let(:user) { User.new }
  let(:user_json) { load_json :user }

  describe "#to_json" do

    it "matches the expected output" do
      expect(user.to_json_api).to eq(user_json)
    end
  end
end
