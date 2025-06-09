require "./../spec_helper"

IPS = ["1.1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"]

describe App::Commands::ManageIPAdmin do
  # Add several IP addresses for test.
  before_all do
    IPS.each do |ip|
      entity = App::Entities::AdminIP.new(ip)
      App::Repositories::AdminIPRepository.new.create(entity)
    end
  end

  it "adds a new IP address into the database" do
    command = App::Commands::ManageIPAdmin.new(App::Repositories::AdminIPRepository.new)
    command.helper_set = ACON::Helper::HelperSet.new(ACON::Helper::Question.new)

    tester = ACON::Spec::CommandTester.new(command)
    tester.inputs "10.10.10.10" # example of the private IP address
    tester.execute(action: "create")
    tester.display.should contain("L'addresse IP 10.10.10.10 est ajoutée dans la liste.")
  end

  it "triggers an error when adding an identical IP address" do
    command = App::Commands::ManageIPAdmin.new(App::Repositories::AdminIPRepository.new)
    command.helper_set = ACON::Helper::HelperSet.new(ACON::Helper::Question.new)

    tester = ACON::Spec::CommandTester.new(command)
    tester.inputs "10.10.10.10" # example of the private IP address
    tester.execute(action: "create")
    tester.display.should contain("Impossible d'ajouter une adresse IP identique.")
  end

  it "displays all IP addresses" do
    command = App::Commands::ManageIPAdmin.new(App::Repositories::AdminIPRepository.new)
    command.helper_set = ACON::Helper::HelperSet.new(ACON::Helper::Question.new)

    tester = ACON::Spec::CommandTester.new(command)
    tester.execute(action: "show")

    IPS.each do |ip|
      tester.display.includes?(ip).should be_true
    end
  end

  it "removes the existent IP address from the database" do
    command = App::Commands::ManageIPAdmin.new(App::Repositories::AdminIPRepository.new)
    command.helper_set = ACON::Helper::HelperSet.new(ACON::Helper::Question.new)

    tester = ACON::Spec::CommandTester.new(command)
    tester.inputs "10.10.10.10" # example of the private IP address
    tester.execute(action: "remove")
    tester.display.should contain("L'addresse IP 10.10.10.10 a bien été supprimée de la liste.")
  end

  it "displays an error when removing an inexistant IP address" do
    command = App::Commands::ManageIPAdmin.new(App::Repositories::AdminIPRepository.new)
    command.helper_set = ACON::Helper::HelperSet.new(ACON::Helper::Question.new)

    tester = ACON::Spec::CommandTester.new(command)
    tester.inputs "10.10.10.10" # example of the private IP address
    tester.execute(action: "remove")
    tester.display.should contain("Cette adresse IP n'existe pas, peut-être qu'elle a déjà été supprimée.")
  end
end
