require "./../../spec_helper"

struct Specs::Controllers::API::MainController < ATH::Spec::APITestCase
  def test_blog_index : Nil
    response = self.get("/blogs/")
    response.headers["Content-Type"].includes?("application/json").should be_true
    response.status_code.should eq(200)
  end

  def test_blog_show : Nil
    response = self.get("/blogs/1")
    response.headers["Content-Type"].includes?("application/json").should be_true
    response.status_code.should eq(200)
  end
end
