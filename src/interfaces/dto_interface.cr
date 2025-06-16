# Interface that groups all DTOs, this is useful for type checking in the resolver.
abstract class App::Interfaces::DTOInterface
  # Before validation, check if all keys are present or not in the HTTP request.
  protected def has_keys?(form_data : App::Services::FormData) : Bool
    {{ @type.instance_vars.map(&.name.stringify) }}.all? do |key|
      form_data.data.has_key?(key)
    end
  end
end
