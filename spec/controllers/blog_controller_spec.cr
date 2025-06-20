require "./../spec_helper"

struct BlogControllerTest < ATH::Spec::APITestCase
  def test_create_blog : Nil
    pending!("Cannot send a form data for the moment.")
  end

  def test_get_blogs : Nil
    self.get("/blogs").body.should eq("[]")

    self.get("/blogs/1").body.should_not be_nil
  end

  def test_update_blog : Nil
    pending!("Cannot send a form data for the moment.")
  end

  def test_delete_blog : Nil
    pending!("Cannot send a form data for the moment.")
  end
end
