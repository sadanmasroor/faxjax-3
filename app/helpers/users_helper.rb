module UsersHelper
  
  #include ActionView::Helpers::FormOptionsHelper
  
  STATES = [
    "Alabama","Alaska","Arizona","Arkansas","California","Colorado",
    "Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho",
    "Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana",
    "Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi",
    "Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey",
    "New Mexico","New York","North Carolina","North Dakota","Ohio",
    "Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota",
    "Tennessee","Texas","Utah","Vermont","Virginia","Washington",
    "West Virginia","Wisconsin", "Wyoming"
  ]

  STATES_ABBREV = [
    "AL","AK","AZ","AR","CA","CO",
    "CT","DE","FL","GA","HI","ID",
    "IL","IN","IA","KS","KY","LA",
    "ME","MD","MA","MI","MN","MS",
    "MO","MT","NE","NV","NH","NJ",
    "NM","NY","NC","ND","OH",
    "OK","OR","PA","RI","SC","SD",
    "TN","TX","UT","VT","VA","WA",
    "WV","WI", "WY"
  ]
  
  
  
   def state_options_for_select(selected = nil)
      state_options = ""
      state_options += options_for_select(STATES.sort, selected)
      return state_options
    end

    def state_abbrev_options_for_select(selected = nil)
      state_options = ""
      state_options += options_for_select(STATES_ABBREV.sort, selected)
      return state_options.html_safe
    end

    def year_options_for_select(selected = nil, start_year = Time.now.year - 50, end_year = Time.now.year)
      year_options = ""

      years = []
      year = end_year
      while year >= start_year
        years << year.to_s
        year -= 1
      end
      
      year_options += options_for_select(years, selected)
      return year_options
    end
  
  
  
  
end