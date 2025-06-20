require "./../spec_helper"

struct CertificationControllerTest < ATH::Spec::APITestCase
  def test_create_certification : Nil
    body = send_form_data do |builder|
      builder.field("name", "Ruby")
      builder.field("has_certificate", "true")
      File.open("dev/data/16/Certificat-de-réussite-Ruby.pdf") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/16/Certificat-de-réussite-Ruby.pdf")
        builder.file("pdf_file", file, metadata, HTTP::Headers{"Content-Type" => "application/pdf"})
      end
    end

    self.post("/certifications/create", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_get_certifications : Nil
    self.get("/certifications").body.should_not eq("[]")
    self.get("/certifications/1").body.should_not be_nil
  end

  def test_update_certification : Nil
    body = send_form_data do |builder|
      builder.field("name", "Another Ruby")
      builder.field("has_certificate", "false")
      File.open("dev/data/16/Certificat-de-réussite-Ruby.pdf") do |file|
        metadata = HTTP::FormData::FileMetadata.new(filename: "dev/data/16/Certificat-de-réussite-Ruby.pdf")
        builder.file("pdf_file", file, metadata, HTTP::Headers{"Content-Type" => "application/pdf"})
      end
    end

    self.put("/certifications/1/update", body, form_data_header)
    self.assert_response_is_successful
  end

  def test_delete_certification : Nil
    self.delete("/certifications/1/delete")
    self.assert_response_is_successful
  end
end
