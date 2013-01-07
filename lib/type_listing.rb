module TypeListing
  def active_and_inactive_listings listings
    inactives = listings.select(&:expired?)
    return (listings - inactives), inactives
  end

  def listing_types listings
    basics = []
    premiums = []
    listings.each do |listing|
      typed_listing = listing.to_type
      case typed_listing
      when BasicListing
        basics << typed_listing
      when Listing
        premiums << typed_listing
      end
    end

    return basics, premiums
  end
end
