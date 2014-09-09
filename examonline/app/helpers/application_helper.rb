module ApplicationHelper
  
  def full_title(page_title) #for title of pages
    base_title = "Online Examination"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
