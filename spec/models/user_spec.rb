require "spec_helper"

describe User do
  
  let(:user) { User.new }
  let(:user_json) { load_json :user }

  describe "#to_json" do

    it "matches the expected output" do
      expect(user.to_json).to eq(user_json.to_s)
    end
  end
end
