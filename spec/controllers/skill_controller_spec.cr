require "./../spec_helper"

struct SkillControllerTest < ATH::Spec::APITestCase
  def test_create_skill : Nil
    body = send_form_data do |builder|
      builder.field("name", "Linux")
      builder.field("description", "Linux is a kernel")
      builder.field("has_colors", "true")
      File.open("dev/data/6/linux.png") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/6/linux.png")
        builder.file("logo", file, metadata, HTTP::Headers{"Content-Type" => "image/png"})
      end
    end

    self.post("/skills/create", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_get_skills : Nil
    self.get("/skills").body.should_not eq("[]")
    self.get("/skills/1").body.should_not be_nil
  end

  def test_update_skill : Nil
    body = send_form_data do |builder|
      builder.field("name", "React")
      builder.field("description", "React is a lib")
      builder.field("has_colors", "true")
      File.open("dev/data/7/react.png") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/7/react.png")
        builder.file("logo", file, metadata, HTTP::Headers{"Content-Type" => "image/png"})
      end
    end

    self.put("/skills/1/update", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_delete_skill : Nil
    self.delete("/skills/1/delete")
    self.assert_response_is_successful
  end
end
