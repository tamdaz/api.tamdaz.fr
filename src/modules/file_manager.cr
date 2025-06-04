module App::Modules::FileManager
  # Save the file into the `storage/` directory.
  private def save_file!(id : Int64, name : String, entity_name : String) : Void
    path_file = @form_data.store_file(name, UUID.random.to_s)
    @file_repository.create(id, entity_name, path_file)
  end

  # Save a new file to replace, if the user have uploaded one.
  private def update_file(id : Int64, name : String, entity_name : String) : Void
    if @form_data.find_file(name)
      path_file = @form_data.store_file(name, UUID.random.to_s)
      @file_repository.update(id, entity_name, path_file)
    end
  end
end
