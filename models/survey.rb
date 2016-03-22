require 'data_mapper'

class Survey
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :created_at, DateTime, default: ->(_, _) { DateTime.now }

  has n, :questions
end
