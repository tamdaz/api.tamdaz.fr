require "./../spec_helper"

struct ProjectControllerTest < ATH::Spec::APITestCase
  def test_create_project : Nil
    body = send_form_data do |builder|
      builder.field("title", "Mon projet")
      builder.field("description", "Mon premier projet")
      builder.field("content", "Mon contenu")
      builder.field("category_id", "1")
      builder.field("realized_at", "2025-01-01")
      builder.field("published_at", nil)
      File.open("dev/data/82/Crygen-miniature.png") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/82/Crygen-miniature.png")
        builder.file("thumbnail", file, metadata, HTTP::Headers{"Content-Type" => "image/png"})
      end
    end

    self.post("/projects/create", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_get_projects : Nil
    self.get("/projects").body.should_not eq("[]")
    self.get("/projects/1").body.should_not be_nil
  end

  def test_update_project : Nil
    body = send_form_data do |builder|
      builder.field("title", "Mon autre projet")
      builder.field("description", "Mon premier projet")
      builder.field("content", "Mon contenu")
      builder.field("category_id", "1")
      builder.field("realized_at", "2025-01-01")
      builder.field("published_at", "2025-02-01")
      File.open("dev/data/81/miniature-sije.png") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/81/miniature-sije.png")
        builder.file("thumbnail", file, metadata, HTTP::Headers{"Content-Type" => "image/png"})
      end
    end

    self.put("/projects/mon-projet/update", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_delete_project : Nil
    self.delete("/projects/mon-autre-projet/delete")
    self.assert_response_is_successful
  end
end
