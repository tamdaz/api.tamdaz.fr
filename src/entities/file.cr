class App::Entities::File
  include DB::Serializable

  property id : Int64

  property model_id : Int64

  property model_type : String

  property path : String
end
