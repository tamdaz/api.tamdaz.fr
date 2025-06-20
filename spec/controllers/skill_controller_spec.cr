require "./../spec_helper"

struct SkillControllerTest < ATH::Spec::APITestCase
  def test_create_skill : Nil
    pending!("Cannot send a form data for the moment.")
  end

  def test_get_skills : Nil
    self.get("/skills").body.should eq("[]")

    self.get("/skills/1").body.should_not be_nil
  end

  def test_update_skill : Nil
    pending!("Cannot send a form data for the moment.")
  end

  def test_delete_skill : Nil
    pending!("Cannot send a form data for the moment.")
  end
end
