# Event that consists of deleting temporary files once data is inserted,
# updated or deleted.
class App::Events::ClearTemporaryFilesEvent < AED::Event
  # ...
end
