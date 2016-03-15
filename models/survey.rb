require 'data_mapper'

class Survey
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :created_at, DateTime

  has n, :questions
end
