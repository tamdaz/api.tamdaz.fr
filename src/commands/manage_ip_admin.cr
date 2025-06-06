@[ACONA::AsCommand(
  name: "tz:admin-ip",
  description: "Manages the IP admin, which allows to manage the portfolio"
)]
class CreateUserCommand < ACON::Command
  protected def configure : Nil
    self.argument("action", :required, "Create, show or remove the IP")
  end

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : Status
    action = input.argument("action")

    case action
    when "create" then add_ip_address
    when "update" then show_ip_address
    when "remove" then remove_ip_address
    else
      return STATUS::INVALID
    end

    Status::SUCCESS
  end

  # Adds an IPv4 address into the database.
  private def add_ip_address : Void
  end

  # Show all IPv4 addresses.
  private def show_ip_address : Void
  end

  # Removes an IPv4 address into the database.
  private def remove_ip_address : Void
  end
end
