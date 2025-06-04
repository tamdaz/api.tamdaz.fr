module App::Modules::Validator
  # Proceeds to the DTO's validation.
  protected def do_validation(dto : AVD::Validatable) : Void
    validate_blog = AVD.validator.validate(dto)

    unless validate_blog.empty?
      send_json(422, validate_blog.to_json)
    end
  end
end
