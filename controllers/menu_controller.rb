module MenuController
  
  # returns html as a list for all menu items
  #
  # menu        - Menu object that you are working with
  # with_link   - Boolean, default to true
  #
  # returns a String
  def get_list_html_for_all_menu_items(menu, with_links=true)
    html = []  
    menu.menu_items.each do |item|
      html << html_line(item, with_links)
    end
    html.join
  end
  
  
  # returns the line of html for this item
  #
  # item      - MenuItem type
  # links?    - Boolean indicating if a link should surround the menu.item
  #
  # returns string of html
  def html_line(item, links)
    if links
      "<li><a href = /#{item.method.method_name}>#{item.user_message}</a></li>"
    else
      "<li>#{item.user_message}</li>"
    end
  end

end