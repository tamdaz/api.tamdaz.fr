require "./../spec_helper"

struct BlogControllerTest < ATH::Spec::APITestCase
  def test_create_blog : Nil
    body = send_form_data do |builder|
      builder.field("title", "Mon premier portfolio")
      builder.field("description", "Ma super description")
      builder.field("content", "# Lorem ipsum dolor sit amet")
      builder.field("category_id", "1")
      builder.field("is_published", "true")
      File.open("dev/data/10/Bienvenue-sur-mon-site-portfolio.png") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/10/Bienvenue-sur-mon-site-portfolio.png")
        builder.file("thumbnail", file, metadata, HTTP::Headers{"Content-Type" => "image/png"})
      end
    end

    self.post("/blogs/create", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_get_blogs : Nil
    self.get("/blogs").body.should_not eq("[]")
    self.get("/blogs/mon-premier-portfolio").body.should_not be_nil
  end

  def test_update_blog : Nil
    body = send_form_data do |builder|
      builder.field("title", "Mon autre portfolio")
      builder.field("description", "Ma super description")
      builder.field("content", "# Lorem ipsum dolor sit amet")
      builder.field("category_id", "1")
      builder.field("is_published", "true")
      File.open("dev/data/10/Bienvenue-sur-mon-site-portfolio.png") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/10/Bienvenue-sur-mon-site-portfolio.png")
        builder.file("thumbnail", file, metadata, HTTP::Headers{"Content-Type" => "image/png"})
      end
    end

    self.put("/blogs/mon-premier-portfolio/update", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_delete_blog : Nil
    self.delete("/blogs/mon-autre-portfolio/delete")
    self.assert_response_is_successful
  end
end
