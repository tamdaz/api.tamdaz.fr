# Exception that will be trigerred when the client puts the data with the same ID/slug.
# For example: if you create a blog with the slug that is the same than another blog,
# then this exception will be raised.
class App::Exceptions::DuplicatedIDException < Exception
  # ...
end
