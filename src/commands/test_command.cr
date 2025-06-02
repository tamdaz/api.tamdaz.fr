@[ADI::Register]
@[ACONA::AsCommand("app:create-user", description: "Create an user")]
class CreateUserCommand < ACON::Command
  protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : Status
    Status::SUCCESS
  end
end
