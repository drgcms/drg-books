class BooksController < DcApplicationController

def page
  params[:path] = 'books'
  dc_process_default_request
end

end
