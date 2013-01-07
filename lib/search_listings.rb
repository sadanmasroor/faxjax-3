module SearchListings

#  set up wild card or single search and run block  if single result found
# passing that result (su[[lied block may redirect]])
  def search_listings_for_code(code, &block)
    option = {}
    option = {:wildcard => true} if code.length != 5
    listings = Listing.find_by_code(code, option)
    if !listings.nil? and listings.kind_of? Listing
      yield listings # a single listing passed here will likely render a show actions
    end
    listings
  end
end