@[ADI::Register]
@[ACONA::AsCommand(
  name: "tz:admin-ip",
  description: "Manages the IP admin, which allows to manage the portfolio"
)]
class App::Commands::ManageIPAdmin < ACON::Command
  def initialize(@admin_ip_repository : App::Repositories::AdminIPRepository)
    super()
  end

  protected def configure : Nil
    self.argument("action", :required, "Create, show or remove the IP")
  end

  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : Status
    style = ACON::Style::Athena.new(input, output)
    action = input.argument("action")

    unless ["create", "show", "remove"].includes? action
      style.error("L'action qui est passée n'existe pas.")
      return Status::INVALID
    end

    if action == "show"
      show_ip_address(style)
      return Status::SUCCESS
    end

    helper = self.helper ACON::Helper::Question

    question = ACON::Question(String).new("Veuillez entrer l'adresse IP : ", "")
    ip_address = helper.ask input, output, question

    Status::INVALID if ip_address.empty?

    case action
    when "create" then add_ip_address(ip_address.as(String), style)
    when "remove" then remove_ip_address(ip_address.as(String), style)
    else               return Status::INVALID
    end

    Status::SUCCESS
  end

  # Adds an IPv4 address into the database.
  private def add_ip_address(ip : String, style : ACON::Style::Athena) : Void
    dto = App::DTO::AdminIPDTO.new(ip)

    if AVD.validator.validate(dto).empty?
      @admin_ip_repository.create(dto)
    end

    style.success("L'addresse IP #{ip} est ajoutée dans la liste.")
  rescue App::Exceptions::DuplicatedIDException
    style.error("Impossible d'ajouter une adresse IP identique.")

    Status::FAILURE
  end

  # Show all IPv4 addresses.
  private def show_ip_address(style : ACON::Style::Athena) : Void
    proc = ->(entity : App::Entities::AdminIP) { [entity.ip] }
    ips = @admin_ip_repository.find_all

    style.note("Il y a #{ips.size} adresses IP dans la liste.")

    style.table(["Adresses IPv4"], ips.map(&proc))
  end

  # Removes an IPv4 address into the database.
  private def remove_ip_address(ip : String, style : ACON::Style::Athena) : Void
    @admin_ip_repository.delete(ip)

    style.success("L'addresse IP #{ip} a bien été supprimée de la liste.")
  rescue App::Exceptions::DataNotFoundException
    style.error("Cette adresse IP n'existe pas, peut-être qu'elle a déjà été supprimée.")

    Status::FAILURE
  end
end
