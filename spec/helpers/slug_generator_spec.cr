require "./../spec_helper"

describe App::Helpers::SlugGenerator do
  it "generates slugs" do
    App::Helpers::SlugGenerator.generate("Hello world").should eq("hello-world")
    App::Helpers::SlugGenerator.generate("Crystal & Ruby!").should eq("crystal-ruby")
    App::Helpers::SlugGenerator.generate("  Multiple   spaces  ").should eq("multiple-spaces")
    App::Helpers::SlugGenerator.generate("Accents éàü").should eq("accents-eau")
    App::Helpers::SlugGenerator.generate("Already-slugified-text").should eq("already-slugified-text")
    # App::Helpers::SlugGenerator.generate("Special_chars@#%").should eq("special-chars")
    App::Helpers::SlugGenerator.generate("").should eq("")
  end
end
