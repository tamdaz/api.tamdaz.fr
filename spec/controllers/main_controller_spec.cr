require "./../spec_helper"

struct Specs::Controllers::MainController < ATH::Spec::APITestCase
  # Tester la page d'accueil.
  def test_main : Nil
    response = self.get("/")
    response.headers["Content-Type"].includes?("text/html").should be_true
    response.status_code.should eq(200)
  end
end
