require "./../spec_helper"

struct CategoryControllerTest < ATH::Spec::APITestCase
  def before_all : Nil
    categories = [
      # >>> blogs
      App::DTO::CategoryDTO.new("Operating System", "Blogs"),
      App::DTO::CategoryDTO.new("Programming languages", "Blogs"),
      # >>> projects
      App::DTO::CategoryDTO.new("Crystal", "Projects"),
      App::DTO::CategoryDTO.new("TypeScript", "Projects"),
      # >>> reports
      App::DTO::CategoryDTO.new("Development", "Reports"),
      App::DTO::CategoryDTO.new("Cybersecurity", "Reports"),
    ]

    categories.each do |category|
      App::Repositories::CategoryRepository.new.create(category)
    end
  end

  def test_create_category : Nil
    header = HTTP::Headers{"Content-Type" => "application/json"}
    body = {:name => "My category", :usage => "Blogs"}.to_json

    self.post("/categories/create", body, header)
    self.assert_response_is_successful
  end

  def test_get_categories : Nil
    self.get("/categories").body.should_not eq("[]")
    self.assert_response_is_successful

    # >>> blogs
    self.get("/categories/operating-system").status.should eq(HTTP::Status::OK)
    self.get("/categories/programming-languages").status.should eq(HTTP::Status::OK)
    # >>> projects
    self.get("/categories/typescript").status.should eq(HTTP::Status::OK)
    self.get("/categories/crystal").status.should eq(HTTP::Status::OK)
    # >>> reports
    self.get("/categories/development").status.should eq(HTTP::Status::OK)
    self.get("/categories/cybersecurity").status.should eq(HTTP::Status::OK)
    # >>> not found categories
    self.get("/categories/error-404").status.should eq(HTTP::Status::NOT_FOUND)
    self.get("/categories/resource-not-found").status.should eq(HTTP::Status::NOT_FOUND)
  end

  def test_update_category : Nil
    header = HTTP::Headers{"Content-Type" => "application/json"}
    body = {:name => "My super category", :usage => "Reports"}.to_json
    self.put("/categories/my-category/update", body, header)
    self.assert_response_is_successful
  end

  def test_delete_category : Nil
    self.delete("/categories/my-super-category/delete")
    self.assert_response_is_successful
  end
end
