# Exception that consists of raising an error when the client wants to search the data
# that doesn't exist.
class App::Exceptions::DataNotFoundException < Exception
  # ...
end
