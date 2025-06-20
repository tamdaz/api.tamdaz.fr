require "./../spec_helper"

struct ReportControllerTest < ATH::Spec::APITestCase
  def test_create_report : Nil
    body = send_form_data do |builder|
      builder.field("title", "Mon compte-rendu")
      builder.field("category_id", "1")
      builder.field("created_at", "2025-01-01")
      File.open("dev/data/96/TAMDA-Zohir---Enumération-des-logins.pdf") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/96/TAMDA-Zohir---Enumération-des-logins.pdf")
        builder.file("pdf_file", file, metadata, HTTP::Headers{"Content-Type" => "application/pdf"})
      end
    end

    self.post("/reports/create", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_get_reports : Nil
    self.get("/reports").body.should_not eq("[]")
    self.get("/reports/1").body.should_not be_nil
  end

  def test_update_report : Nil
    body = send_form_data do |builder|
      builder.field("title", "Mon autre compte-rendu")
      builder.field("category_id", "1")
      builder.field("created_at", "2026-01-01")
      File.open("dev/data/75/TAMDA-Zohir---Failles-XSS.pdf") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/75/TAMDA-Zohir---Failles-XSS.pdf")
        builder.file("pdf_file", file, metadata, HTTP::Headers{"Content-Type" => "application/pdf"})
      end
    end

    self.put("/reports/1/update", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_delete_report : Nil
    self.delete("/reports/1/delete")
    self.assert_response_is_successful
  end
end
