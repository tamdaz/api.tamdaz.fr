require "./../spec_helper"

struct CertificationControllerTest < ATH::Spec::APITestCase
  def test_create_certification : Nil
    # TODO: Complete this method.
  end

  def test_get_certifications : Nil
    self.get("/certifications").body.should eq("[]")

    self.get("/certifications/1").body.should_not be_nil
  end

  def test_update_certification : Nil
    # TODO: Complete this method.
  end

  def test_delete_certification : Nil
    # TODO: Complete this method.
  end
end
