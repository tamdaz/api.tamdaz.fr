require "./../spec_helper"

struct ProjectControllerTest < ATH::Spec::APITestCase
  def test_create_project : Nil
    # TODO: Complete this method.
  end

  def test_get_projects : Nil
    self.get("/projects").body.should eq("[]")

    self.get("/projects/1").body.should_not be_nil
  end

  def test_update_project : Nil
    # TODO: Complete this method.
  end

  def test_delete_project : Nil
    # TODO: Complete this method.
  end
end
