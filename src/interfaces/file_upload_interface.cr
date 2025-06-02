# This is an interface that can be implemented to controllers. This enables to add a logic
# to save and update one or several files.
# INFO: Once that the issue https://github.com/athena-framework/athena/issues/442
# is solved, this interface will be deprecated and the `@[ATHA::MapUploadedFile]`
# annotation will be used instead.
module App::Interfaces::FileUploadInterface
  # Save a file into the storage system.
  # This is mandatory when inserting data into the DB.
  abstract def save_file!(id : Int64, name : String) : Void

  # Replace and save a file into the storage system.
  # This is optional when updating data into the DB.
  abstract def update_file(id : Int64, name : String) : Void
end
