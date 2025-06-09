require "./../spec_helper"

struct TimelineControllerTest < ATH::Spec::APITestCase
  def before_all : Nil
    timelines = [
      App::DTO::TimelineDTO.new(Time.utc(2025, 1, 1), Time.utc(2025, 2, 1), "Timeline (exp.) 1", "experience"),
      App::DTO::TimelineDTO.new(Time.utc(2025, 3, 1), Time.utc(2025, 4, 1), "Timeline (exp.) 2", "experience"),
      App::DTO::TimelineDTO.new(Time.utc(2025, 5, 1), Time.utc(2025, 6, 1), "Timeline (exp.) 3", "experience"),
      App::DTO::TimelineDTO.new(Time.utc(2026, 1, 1), Time.utc(2026, 2, 1), "Timeline (form.) 1", "formation"),
      App::DTO::TimelineDTO.new(Time.utc(2026, 3, 1), Time.utc(2026, 4, 1), "Timeline (form.) 2", "formation"),
      App::DTO::TimelineDTO.new(Time.utc(2026, 5, 1), Time.utc(2026, 6, 1), "Timeline (form.) 3", "formation"),
    ]

    timelines.each do |timeline|
      App::Repositories::TimelineRepository.new.create(timeline)
    end
  end

  def test_create_timeline : Nil
    header = HTTP::Headers{"Content-Type" => "application/json"}
    body = {
      :date_start  => "2027-01-01T00:00:00Z",
      :date_end    => "2027-02-01T00:00:00Z",
      :description => "New Timeline",
      :type        => "experience",
    }.to_json
    self.post("/timelines/create", body, header).status.should eq(HTTP::Status::OK)
  end

  def test_get_timelines : Nil
    self.get("/timelines").body.should_not eq("[]")

    self.get("/timelines/1").status.should eq(HTTP::Status::OK)
    self.get("/timelines/2").status.should eq(HTTP::Status::OK)
    self.get("/timelines/3").status.should eq(HTTP::Status::OK)
    self.get("/timelines/4").status.should eq(HTTP::Status::OK)
    self.get("/timelines/5").status.should eq(HTTP::Status::OK)
    self.get("/timelines/6").status.should eq(HTTP::Status::OK)
    self.get("/timelines/7").status.should eq(HTTP::Status::OK)
    self.get("/timelines/8").status.should eq(HTTP::Status::NOT_FOUND)
    self.get("/timelines/9").status.should eq(HTTP::Status::NOT_FOUND)
    self.get("/timelines/10").status.should eq(HTTP::Status::NOT_FOUND)
  end

  def test_update_timeline : Nil
    header = HTTP::Headers{"Content-Type" => "application/json"}
    body = {
      :date_start  => "2027-03-01T00:00:00Z",
      :date_end    => "2027-04-01T00:00:00Z",
      :description => "Updated Timeline",
      :type        => "formation",
    }.to_json
    self.post("/timelines/create", body, header).status.should eq(HTTP::Status::OK)
  end

  def test_delete_timeline : Nil
    self.delete("/timelines/7/delete").status.should eq(HTTP::Status::OK)
  end
end
