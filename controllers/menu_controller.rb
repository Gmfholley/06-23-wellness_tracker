module MenuController
  
  # This module creates html for each MenuItem for my menu.erb file
  #     Given a Menu object, this module will generate html to show each MenuItem in a html List
  #     These methods also allows you to surround the MenuItem in html with links or not
  ##################################################  
  
  
  
  # returns html as a list for all menu items
  #
  # menu        - Menu object that you are working with
  # with_link   - Boolean, default to true
  #
  # returns a String
  def get_list_html_for_all_menu_items(menu, with_links=true)
    html = ["<ul>"]  
    menu.menu_items.each do |item|
      html << "<li>"
      html <<   "<a href = /#{item.method.method_name}>" if with_links
      html <<       html_user_message_list(item)
      html <<   "</a>" if with_links      
      html << "</li>"
    end
    html << "</ul>"
    html.join
  end
  
  # returns String of table html for this menu
  #
  # menu        - Menu object
  # with_links  - optional Boolean, defaults to true
  #
  # returns a String
  def get_table_html_for_all_menu_items(menu, with_links=true)
    html = ["<table>"]  
    html << table_header
    menu.menu_items.each do |item|
      html << "<tr>"
      html <<   html_table_row(item, with_links)
      html << "</tr>"
    end
    html << "</table>"
    html.join
  end
  
  # returns the table header html for this class's table
  #
  # you have access to @class_name from original router methods
  #
  # returns String of html creating the table header
  def table_header
    header = ["<tr>"]
    m = @class_name.new
    m.display_fields.each do |field|
      header << 
      "<th>
        #{field.humanize}
      </th>"
    end
    header << "</tr>"
    header.join
  end

  # returns a String of html forming a row in a table of this item's user_message Array
  #
  # item        - MenuItem object
  # with_link   - Boolean of whether to add links
  #
  # returns a String
  def html_table_row(item, with_links)
    html = []
    item.user_message.each do |message|
      html << "<td>"
      html <<   "<a href = /#{item.method.method_name}>" if with_links
      html <<      "#{message}"
      html <<   "</a>" if with_links
      html << "</td>"
    end
    html.join
  end
  
  # returns all items in the user_message array joined together
  def html_user_message_list(item)
    item.user_message.join
  end

end