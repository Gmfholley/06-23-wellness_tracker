module CreateController
  
  # This module creates most of the html that is dynamically loaded from Ruby
  # Given an object that has the database_connector Module included/extended, I can dynamically create
  #     the create.erb page by loading its: foreign keys, non-foreign key parameters, and errors
  #
  #
  #
  # The Create page has three sections:
  #       1) Foreign Key section, displayed in select type html fields with options for each choice
  #       2) Non Foreign Key section, displayed in input fields
  #       3) Error section, displayed in simple <br> lines at the top of the page
  #   Note: all field names are stored in a Hash called 'create_form'
  
  
  
  
################
# html for non-foreign key select fields
###############  
  
  def get_list_html_for_non_foreign_key_fields(object)
    html = []
    object.non_foreign_key_fields.each do |field|
      html <<
        "<p>
          <label for = '#{field}' >
            Select your #{field}:
          </label>
          <input type = 'text' 
            name = create_form[#{field}]
            placeholder = 'Type in the #{field}'
            value = '#{object.send(field)}'>
          </input>
        </p>"
    end
    html.join
  end
  
  
  
# <% @m.non_foreign_key_fields.each do |field| %>
#   <p>
#     <label for = "<%= field %> ">
#       Select your <%= field %>:
#     </label>
#     <input type= "text" name = create_form[<%= field %>] field placeholder= "Type in the <%= field %>" value = "<%= @m.send(field) %>" >
#     </input>
#   </p>
# <% end %>
  
################
# html for Foreign Key select drop downs
###############

  #
  # returns String of html to display foreign keys for the object as select drop-down
  #
  # returns String
  def get_list_html_for_foreign_key_fields(object)
    html = []
    object.foreign_key_fields.each_with_index do |foreign_key, x|
      html << 
        "<p>
          <label for #{foreign_key}>
            Select your #{foreign_key}:
          </label>
          <select name = 'create_form[#{foreign_key}]'>
            #{get_list_html_foreign_key_choices(object, foreign_key, object.foreign_key_choices[x])}
          </select>
        </p>"
    end
    html.join
  end
  
  # returns string of html for each of the options in a select html variable
  #
  # returns String
  def get_list_html_foreign_key_choices(object, foreign_key, foreign_key_choices_array)
    html = []
    foreign_key_choices_array.each do |choice|
      html <<
      "<option value = #{choice.id} 
        #{is_selected_html?(object, foreign_key, choice)}>
        choice.name
       </option>"
    end
    html.join
  end
  
  # returns a string based on whether the object's foreign key is the current foreign_key_choice or not
  #
  # returns String
  def is_selected_html?(object, foreign_key, foreign_key_choice)
    if object.send(foreign_key).id == foreign_key_choice.id
      " selected "
    else
      ""
    end
  end


end