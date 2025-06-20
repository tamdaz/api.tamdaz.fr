require "./../spec_helper"

struct ProjectControllerTest < ATH::Spec::APITestCase
  def test_create_project : Nil
    pending!("Cannot send a form data for the moment.")
  end

  def test_get_projects : Nil
    self.get("/projects").body.should eq("[]")

    self.get("/projects/1").body.should_not be_nil
  end

  def test_update_project : Nil
    pending!("Cannot send a form data for the moment.")
  end

  def test_delete_project : Nil
    pending!("Cannot send a form data for the moment.")
  end
end
