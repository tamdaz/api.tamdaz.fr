require "./../spec_helper"

struct TWControllerTest < ATH::Spec::APITestCase
  def before_all : Nil
    tws = [
      App::DTO::TWDTO.new(
        title: "My title",
        description: "My description",
        image_url: "https://fake-image.org/my_image.webp",
        source_url: "https://fake-image.org",
        published_at: Time.utc(2024, 1, 1),
        source: "My source"
      ),
      App::DTO::TWDTO.new(
        title: "My another title",
        description: "My another description",
        image_url: "https://another-fake-image.org/my_image.webp",
        source_url: "https://another-fake-image.org",
        published_at: Time.utc(2024, 1, 1),
        source: "My another source"
      ),
    ]

    # ameba:disable Naming/BlockParameterName
    tws.each do |tw|
      App::Repositories::TWRepository.new.create(tw)
    end
  end

  def test_create_tw : Nil
    header = HTTP::Headers{"Content-Type" => "application/json"}
    body = {
      :title        => "My new title",
      :description  => "My new description",
      :image_url    => "https://new-fake-image.org/my_image.webp",
      :source_url   => "https://new-fake-image.org",
      :published_at => Time.utc(2024, 1, 1),
      :source       => "My new source",
    }.to_json

    self.post("/tws/create", body, header).status.should eq(HTTP::Status::OK)
  end

  def test_get_tws : Nil
    self.get("/tws").body.should_not eq("[]")

    self.get("/tws/1").status.should eq(HTTP::Status::OK)
    self.get("/tws/2").status.should eq(HTTP::Status::OK)
    self.get("/tws/3").status.should eq(HTTP::Status::OK)
    self.get("/tws/4").status.should eq(HTTP::Status::NOT_FOUND)
    self.get("/tws/5").status.should eq(HTTP::Status::NOT_FOUND)
    self.get("/tws/6").status.should eq(HTTP::Status::NOT_FOUND)
  end

  def test_update_tw : Nil
    header = HTTP::Headers{"Content-Type" => "application/json"}
    body = {
      :title        => "My updated title",
      :description  => "My updated description",
      :image_url    => "https://updated-fake-image.org/my_image.webp",
      :source_url   => "https://updated-fake-image.org",
      :published_at => Time.utc(2024, 1, 1),
      :source       => "My updated source",
    }.to_json

    self.put("/tws/3/update", body, header).status.should eq(HTTP::Status::OK)
  end

  def test_delete_tw : Nil
    self.delete("/tws/3/delete").status.should eq(HTTP::Status::OK)
  end
end
