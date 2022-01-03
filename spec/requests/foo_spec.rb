require 'rails_helper'

RSpec.describe "Foos", type: :request do
  describe "GET /bar" do
    it "returns http success" do
      get "/foo/bar"
      expect(response).to have_http_status(:success)
    end
  end

end
