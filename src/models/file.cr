class App::Models::File < Granite::Base
  table files

  column id : Int64, primary: true

  column model_id : Int64

  column model_type : String

  column path : String
end
