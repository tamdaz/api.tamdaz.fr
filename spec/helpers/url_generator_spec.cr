require "./../spec_helper"

describe App::Helpers::URLGenerator do
  it "generates the URLs" do
    App::Helpers::URLGenerator.generate("image.png").should eq("http://127.0.0.1:3000/uploads/image.png")
    App::Helpers::URLGenerator.generate("01234.png").should eq("http://127.0.0.1:3000/uploads/01234.png")
  end
end
