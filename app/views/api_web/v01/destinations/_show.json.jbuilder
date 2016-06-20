json.extract! destination, :name, :street, :detail, :postalcode, :city, :country, :lat, :lng, :comment, :phone_number, :geocoding_accuracy, :geocoding_level
json.destination_id destination.id
json.error !destination.position?

color = nil
icon = nil
tags = destination.tags
json.visits destination.visits do |visit|
  json.extract! visit, :id, :quantity, :tag_ids
  json.index_visit (destination.visits.index(visit) + 1) if destination.visits.size > 1
  json.ref visit.ref if @customer.enable_references
  take_over = visit.take_over && l(visit.take_over.utc, format: :hour_minute_second)
  json.take_over take_over
  json.duration take_over
  json.open_close visit.open || visit.close
  json.open visit.open && l(visit.open.utc, format: :hour_minute)
  json.close visit.close && l(visit.close.utc, format: :hour_minute)
  tags = visit.tags | destination.tags
  if !tags.empty?
    json.tags_present do
      json.tags do
        json.array! tags, :label
      end
    end
    color ||= tags.find(&:color)
    icon ||= tags.find(&:icon)
  end
end
if destination.visits.size == 0
  if !tags.empty?
    json.tags_present do
      json.tags do
        json.array! tags, :label
      end
    end
    color ||= tags.find(&:color)
    icon ||= tags.find(&:icon)
  end
end
# TODO: display several icons
(json.color color.color) if color
(json.icon icon.icon) if icon
