require "./../spec_helper"

struct ReportControllerTest < ATH::Spec::APITestCase
  def test_create_report : Nil
    # TODO: Complete this method.
  end

  def test_get_reports : Nil
    self.get("/reports").body.should eq("[]")

    self.get("/reports/1").body.should_not be_nil
  end

  def test_update_report : Nil
    # TODO: Complete this method.
  end

  def test_delete_report : Nil
    # TODO: Complete this method.
  end
end
